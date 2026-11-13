import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/cabin_session.dart';
import '../../core/providers.dart';
import '../../core/report.dart';
import '../../core/scenarios.dart';
import '../../core/serum_definition.dart';
import '../../core/serum_hardware.dart';
import '../../widgets/common.dart';

/// Serum bölmesi / serum kabini: tanım (kapak sayısı, raflar, avadanlıklar,
/// kilit) ve testler (kapak açma, raf kilitleri, avadanlık kilitleri, akış).
/// Tanım yalnızca bu oturumda tutulur; hiçbir yere kaydedilmez.
class SerumPage extends ConsumerStatefulWidget {
  const SerumPage({super.key});

  @override
  ConsumerState<SerumPage> createState() => _SerumPageState();
}

class _SerumPageState extends ConsumerState<SerumPage> {
  /// Çalışan işlemin anahtarı (kapak / raf / avadanlık); null → boşta.
  String? _busy;

  /// Kapak anahtarı → son ham durum ve açma sonucu.
  final Map<String, String> _lidText = {};
  final Map<String, TestStatus> _lidState = {};

  /// Açma sonrası teknisyen onayı bekleyen kapak.
  String? _awaitingLid;

  /// Raf / avadanlık anahtarı → son kart cevabı.
  final Map<String, TrayReading> _readings = {};

  // Akış testi
  String? _flowKey;
  bool _flowCancel = false;
  final Map<TrayFlowStep, (TestStatus, String)> _flow = {};
  TrayReading? _flowLive;

  SerumHardware get _hw => SerumHardware(serial: ref.read(serialServiceProvider), ops: ref.read(cabinOpsProvider));

  TestReport get _report => ref.read(testReportProvider);

  /// Test listesiyle ortak senaryo sonucu.
  void _scenario(String id, TestStatus status, String detail) =>
      ref.read(scenarioResultsProvider.notifier).set(id, status, detail: detail);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _sync(ref.read(cabinSessionProvider).active));
  }

  @override
  void dispose() {
    _flowCancel = true;
    super.dispose();
  }

  void _sync(dynamic _) {
    final notifier = ref.read(serumDefinitionsProvider.notifier);
    notifier.syncFrom(ref.read(cabinSessionProvider).active);
    for (final address in ref.read(serumDefinitionsProvider).keys) {
      notifier.loadClientLayouts(address);
    }
  }

  static String _lidKey(SerumTargetDef t, SerumLidDef l) => '${t.addressIndex}-${l.lidNo}';
  static String _shelfKey(SerumTargetDef t, SerumLidDef l, SerumShelfLayout s) => '${_lidKey(t, l)}-${s.orderNo}';
  static String _trayKey(SerumTargetDef t, SerumLidDef l, SerumShelfLayout s, int i) => '${_shelfKey(t, l, s)}-$i';

  static String _where(SerumTargetDef t, SerumLidDef l) =>
      '${t.letter} kapak ${l.lidNo} (satır ${l.row.toString().padLeft(2, '0')}, port ${l.port})';

  // ── Kapak ──────────────────────────────────────────────────────────

  Future<void> _openLid(SerumTargetDef t, SerumLidDef l) async {
    final key = _lidKey(t, l);
    setState(() {
      _busy = key;
      _awaitingLid = null;
      _lidText[key] = 'Açılıyor…';
      _lidState[key] = TestStatus.running;
    });
    String? error;
    try {
      await _hw.openLid(t.addressIndex, l.row, l.port);
    } catch (e) {
      error = '$e';
    }
    // Kartın bildirdiği durum (en fazla ~1,5 sn beklenir).
    String? status;
    for (var i = 0; i < 3; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      status = await _hw.lidStatus(t.addressIndex, l.row, l.port);
      if (SerumHardware.lidIsOpen(status)) break;
    }
    await _hw.release(t.addressIndex);
    final opened = SerumHardware.lidIsOpen(status);
    if (error != null && !opened) {
      _scenario(ScenarioIds.serumLid(t.addressIndex, l.lidNo), TestStatus.failed, 'Açılamadı: $error');
    }
    _report.add(
      'Serum kapağı aç — ${_where(t, l)}',
      error == null || opened ? StepResult.info : StepResult.fail,
      detail: [if (error != null) 'Açma komutu: $error', 'Kart durumu: ${SerumHardware.lidStatusText(status)}'].join('\n'),
    );
    if (!mounted) return;
    setState(() {
      _busy = null;
      _lidText[key] = error != null && !opened
          ? 'Açılamadı: $error'
          : 'Kart: ${SerumHardware.lidStatusText(status)} — kapak fiziksel olarak açıldı mı?';
      _lidState[key] = error != null && !opened ? TestStatus.failed : TestStatus.running;
      _awaitingLid = error != null && !opened ? null : key;
    });
  }

  void _confirmLid(SerumTargetDef t, SerumLidDef l, bool opened) {
    final key = _lidKey(t, l);
    _report.add('Gözlem: ${_where(t, l)} ${opened ? 'açıldı' : 'AÇILMADI'}', opened ? StepResult.ok : StepResult.fail);
    _scenario(
      ScenarioIds.serumLid(t.addressIndex, l.lidNo),
      opened ? TestStatus.passed : TestStatus.failed,
      opened ? 'Açıldı (teknisyen onayı)' : 'Açılmadı (teknisyen gözlemi)',
    );
    setState(() {
      _awaitingLid = null;
      _lidState[key] = opened ? TestStatus.passed : TestStatus.failed;
      _lidText[key] = opened ? 'Açıldı (teknisyen onayı)' : 'Açılmadı (teknisyen gözlemi)';
    });
  }

  Future<void> _readLid(SerumTargetDef t, SerumLidDef l) async {
    final key = _lidKey(t, l);
    setState(() => _busy = key);
    final status = await _hw.lidStatus(t.addressIndex, l.row, l.port);
    await _hw.release(t.addressIndex);
    _report.add(
      'Serum kapağı durumu — ${_where(t, l)}',
      status == null ? StepResult.fail : StepResult.info,
      detail: SerumHardware.lidStatusText(status),
    );
    if (!mounted) return;
    setState(() {
      _busy = null;
      _lidText[key] = 'Kart: ${SerumHardware.lidStatusText(status)}';
      _lidState.putIfAbsent(key, () => TestStatus.info);
      if (status == null) _lidState[key] = TestStatus.failed;
    });
  }

  // ── Raf kilit kartı ───────────────────────────────────────────────

  Future<void> _shelfCommand(SerumTargetDef t, SerumLidDef l, SerumShelfLayout s, TrayLockAction action) async {
    final key = _shelfKey(t, l, s);
    final card = SerumRules.lockCardId(s);
    setState(() => _busy = key);
    final (raw, res) = await _hw.tray(card, action);
    final reading = TrayReading.of(res);
    final label = switch (action) {
      TrayLockAction.lockAll => 'Tümünü kilitle (k)',
      TrayLockAction.unlockAll => 'Tümünü serbest bırak (x)',
      _ => action.code,
    };
    _report.add(
      'Raf ${s.orderNo} kilit kartı $card · $label — ${_where(t, l)}',
      reading.status == TestStatus.failed ? StepResult.fail : StepResult.info,
      detail: '${raw ?? '(cevap yok)'} → ${reading.text}',
    );
    if (!mounted) return;
    setState(() {
      _busy = null;
      _readings[key] = TrayReading(reading.status, '$label: ${reading.text}');
    });
  }

  Future<void> _shelfCardCheck(SerumTargetDef t, SerumLidDef l, SerumShelfLayout s) async {
    final key = _shelfKey(t, l, s);
    final card = SerumRules.lockCardId(s);
    setState(() => _busy = key);
    final present = await _hw.trayCardPresent(card);
    _scenario(
      ScenarioIds.lockCard(t.addressIndex, l.lidNo, s.orderNo),
      present ? TestStatus.passed : TestStatus.failed,
      present ? 'Kilit kartı cevap verdi' : 'Kilit kartı cevap vermedi',
    );
    _report.add(
      'Raf ${s.orderNo} kilit kartı $card ${present ? 'cevap verdi' : 'CEVAP VERMEDİ'} — ${_where(t, l)}',
      present ? StepResult.ok : StepResult.fail,
    );
    if (!mounted) return;
    setState(() {
      _busy = null;
      _readings[key] = present
          ? TrayReading(TestStatus.passed, 'Kilit kartı $card cevap verdi')
          : TrayReading(TestStatus.failed, 'Kilit kartı $card cevap vermedi');
    });
  }

  // ── Avadanlık ─────────────────────────────────────────────────────

  Future<void> _trayCommand(
    SerumTargetDef t,
    SerumLidDef l,
    SerumShelfLayout s,
    int index,
    TrayLockAction action,
  ) async {
    final key = _trayKey(t, l, s, index);
    final card = SerumRules.lockCardId(s);
    final port = SerumRules.trayPorts(s)[index];
    setState(() => _busy = key);
    final (raw, res) = await _hw.tray(card, action, port: port);
    final reading = TrayReading.of(res);
    _report.add(
      'Avadanlık ${SerumRules.sizeLabel(s.trays[index].size).toLowerCase()} · raf ${s.orderNo} · kart $card port $port · '
      '${_trayActionLabel(action)} — ${_where(t, l)}',
      reading.status == TestStatus.failed ? StepResult.fail : StepResult.info,
      detail: '${raw ?? '(cevap yok)'} → ${reading.text}',
    );
    if (!mounted) return;
    setState(() {
      _busy = null;
      _readings[key] = reading;
    });
  }

  static String _trayActionLabel(TrayLockAction a) => switch (a) {
    TrayLockAction.open => 'kilidi aç (o)',
    TrayLockAction.cancel => 'açmayı iptal (c)',
    TrayLockAction.status => 'durum (s)',
    TrayLockAction.keypadValue => 'tuş değeri (t)',
    TrayLockAction.lockAll => 'tümünü kilitle (k)',
    TrayLockAction.unlockAll => 'tümünü serbest bırak (x)',
  };

  Future<void> _runFlow(SerumTargetDef t, SerumLidDef l, SerumShelfLayout s, int index) async {
    final key = _trayKey(t, l, s, index);
    final card = SerumRules.lockCardId(s);
    final port = SerumRules.trayPorts(s)[index];
    final what =
        '${_where(t, l)} · raf ${s.orderNo} · ${SerumRules.sizeLabel(s.trays[index].size).toLowerCase()} avadanlık '
        '(kart $card, port $port)';
    setState(() {
      _busy = key;
      _flowKey = key;
      _flowCancel = false;
      _flow.clear();
      _flowLive = null;
    });
    _report.add('Avadanlık akış testi başladı', StepResult.info, detail: what);
    final ok = await _hw.runTrayFlow(
      address: t.addressIndex,
      row: l.row,
      lidPort: l.port,
      deviceId: card,
      trayPort: port,
      isCancelled: () => _flowCancel || !mounted,
      onLive: (r) {
        if (mounted) setState(() => _flowLive = r);
      },
      onStep: (step, status, detail) {
        if (status != TestStatus.running) {
          _report.add(
            'Akış — ${step.label}',
            status == TestStatus.passed ? StepResult.ok : StepResult.fail,
            detail: detail,
          );
        }
        if (mounted) setState(() => _flow[step] = (status, detail));
      },
    );
    _report.add('Avadanlık akış testi ${ok ? 'tamamlandı' : 'yarıda kaldı'}', ok ? StepResult.ok : StepResult.fail, detail: what);
    _scenario(
      ScenarioIds.trayFlow(t.addressIndex, l.lidNo, s.orderNo, index),
      ok ? TestStatus.passed : TestStatus.failed,
      ok ? 'Avadanlık çekildi, yerine itildi; kapak kapandı' : 'Akış testi yarıda kaldı',
    );
    if (!mounted) return;
    setState(() {
      _busy = null;
      _readings[key] = ok
          ? const TrayReading(TestStatus.passed, 'Akış testi başarılı')
          : const TrayReading(TestStatus.failed, 'Akış testi başarısız');
    });
  }

  // ── Tanım düzenleme ───────────────────────────────────────────────

  void _updateShelf(SerumTargetDef t, SerumLidDef l, SerumShelfLayout s) =>
      ref.read(serumDefinitionsProvider.notifier).updateShelf(t.addressIndex, l.lidNo, s);

  void _addDefinitionToReport(SerumTargetDef t) {
    _report.add('Serum tanımı — ${t.title}', StepResult.info, detail: t.describe().join('\n'));
    showMessage(context, 'Tanım rapora eklendi.');
  }

  // ── UI ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen(cabinSessionProvider.select((s) => s.active), (_, next) => _sync(next));
    final active = ref.watch(cabinSessionProvider.select((s) => s.active));
    final targets = ref.watch(serumDefinitionsProvider).values.toList()
      ..sort((a, b) => a.addressIndex.compareTo(b.addressIndex));
    final connected = ref.watch(sessionProvider.select((s) => s.port != null));

    return ListView(
      padding: const EdgeInsets.all(MedSpacing.xl2),
      children: [
        if (active == null)
          const SectionCard(
            title: 'Serum',
            child: Text('Önce Kabin sayfasında client tanımıyla devam edin ya da kabini tarayın.'),
          )
        else if (targets.isEmpty)
          const SectionCard(
            title: 'Serum',
            child: Text('Bu kabin tanımında serum bölmesi ya da serum kabini yok.'),
          )
        else ...[
          if (!connected) const Padding(padding: EdgeInsets.only(bottom: MedSpacing.lg), child: NotConnectedHint()),
          for (final t in targets) _targetCard(t, connected),
        ],
      ],
    );
  }

  Widget _targetCard(SerumTargetDef t, bool connected) {
    final fromClient = t.lids.any((l) => l.fromClient);
    return SectionCard(
      title: t.title,
      trailing: TextButton.icon(
        onPressed: () => _addDefinitionToReport(t),
        icon: const Icon(Icons.post_add, size: 18),
        label: const Text('Tanımı rapora ekle'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fromClient
                ? 'Raf yerleşimi client tanımından yüklendi. Burada yaptığınız değişiklikler yalnızca bu testte kullanılır, kaydedilmez.'
                : 'Raf yerleşimini burada tanımlayın. Tanım yalnızca bu testte kullanılır, kaydedilmez.',
            style: hintStyle(fontSize: 12),
          ),
          if (t.isCabinet) ...[
            const SizedBox(height: MedSpacing.lg),
            Row(
              children: [
                Text('Kapak sayısı', style: MedTextStyles.titleSm()),
                const SizedBox(width: MedSpacing.lg),
                SegmentedButton<int>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: [
                    for (var n = 1; n <= DeviceConstants.maxSerumLids; n++) ButtonSegment(value: n, label: Text('$n')),
                  ],
                  selected: t.lids.isEmpty ? <int>{} : {t.lids.length},
                  onSelectionChanged: _busy != null
                      ? null
                      : (v) {
                          if (v.isEmpty) return;
                          ref.read(serumDefinitionsProvider.notifier).setLidCount(t.addressIndex, v.first);
                          _report.add('Serum kabini ${t.letter}: kapak sayısı ${v.first}', StepResult.info);
                        },
                ),
                const SizedBox(width: MedSpacing.lg),
                if (t.needsLidCount)
                  const StatusBadge(status: TestStatus.warning, label: 'Tanım bekliyor')
                else
                  Text('Kapak N → port N', style: hintStyle(fontSize: 12)),
              ],
            ),
          ],
          for (final l in t.lids) _lidCard(t, l, connected),
        ],
      ),
    );
  }

  Widget _lidCard(SerumTargetDef t, SerumLidDef l, bool connected) {
    final key = _lidKey(t, l);
    final idle = connected && _busy == null;
    final state = _lidState[key] ?? TestStatus.pending;
    return Container(
      margin: const EdgeInsets.only(top: MedSpacing.xl),
      padding: const EdgeInsets.all(MedSpacing.xl),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined, color: MedColors.blue),
              const SizedBox(width: MedSpacing.md),
              Text(t.isCabinet ? 'Kapak ${l.lidNo}' : 'Serum bölmesi', style: MedTextStyles.titleMd()),
              const SizedBox(width: MedSpacing.lg),
              Text('satır ${l.row.toString().padLeft(2, '0')} · port ${l.port}', style: monoStyle()),
              const Spacer(),
              StatusBadge(status: state),
              const SizedBox(width: MedSpacing.lg),
              BusyButton(
                label: 'Kapağı aç',
                icon: Icons.lock_open,
                busy: _busy == key,
                onPressed: idle ? () => _openLid(t, l) : null,
              ),
              const SizedBox(width: MedSpacing.md),
              OutlinedButton(onPressed: idle ? () => _readLid(t, l) : null, child: const Text('Durum oku')),
            ],
          ),
          if (_lidText[key] != null) ...[
            const SizedBox(height: MedSpacing.md),
            Text(_lidText[key]!, style: TextStyle(color: state.color)),
          ],
          if (_awaitingLid == key) ...[
            const SizedBox(height: MedSpacing.md),
            Wrap(
              spacing: MedSpacing.md,
              children: [
                ActionChip(
                  avatar: Icon(TestStatus.passed.icon, color: TestStatus.passed.color, size: 18),
                  label: const Text('Açıldı'),
                  onPressed: () => _confirmLid(t, l, true),
                ),
                ActionChip(
                  avatar: Icon(TestStatus.failed.icon, color: TestStatus.failed.color, size: 18),
                  label: const Text('Açılmadı'),
                  onPressed: () => _confirmLid(t, l, false),
                ),
              ],
            ),
          ],
          for (final s in l.shelves) _shelfSection(t, l, s, connected),
          if (_flowKey != null && _flowKey!.startsWith('$key-')) _flowPanel(),
        ],
      ),
    );
  }

  Widget _shelfSection(SerumTargetDef t, SerumLidDef l, SerumShelfLayout s, bool connected) {
    final shelfKey = _shelfKey(t, l, s);
    final idle = connected && _busy == null;
    final editable = _busy == null;
    final hasTrays = !s.isOpenShelf;
    final reading = _readings[shelfKey];
    return Padding(
      padding: const EdgeInsets.only(top: MedSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MedSpacing.lg,
            runSpacing: MedSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: 56, child: Text('Raf ${s.orderNo}', style: MedTextStyles.titleSm())),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: true, label: Text('Açık raf')),
                  ButtonSegment(value: false, label: Text('Avadanlık')),
                ],
                selected: {s.isOpenShelf},
                onSelectionChanged: editable
                    ? (v) => _updateShelf(t, l, v.first ? s.toOpenShelf() : s.toTrayShelf())
                    : null,
              ),
              if (hasTrays) ...[
                FilterChip(
                  label: const Text('Elektromanyetik kilit'),
                  selected: s.isLocked,
                  onSelected: editable
                      ? (v) => _updateShelf(
                          t,
                          l,
                          s.copyWith(lockType: v ? SerumShelfLockType.locked : SerumShelfLockType.unlocked),
                        )
                      : null,
                ),
                for (final size in SerumTraySize.trayValues)
                  TextButton.icon(
                    onPressed: editable && s.canAdd(size)
                        ? () => _updateShelf(t, l, s.copyWith(trays: [...s.trays, SerumTray(size: size)]))
                        : null,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(SerumRules.sizeLabel(size)),
                  ),
              ],
            ],
          ),
          const SizedBox(height: MedSpacing.md),
          _shelfStrip(t, l, s, connected),
          if (hasTrays && s.isLocked) ...[
            const SizedBox(height: MedSpacing.md),
            Wrap(
              spacing: MedSpacing.md,
              runSpacing: MedSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Kilit kartı ${SerumRules.lockCardId(s).toString().padLeft(2, '0')}', style: monoStyle()),
                OutlinedButton(
                  onPressed: idle ? () => _shelfCardCheck(t, l, s) : null,
                  child: const Text('Kart cevap veriyor mu?'),
                ),
                OutlinedButton.icon(
                  onPressed: idle ? () => _shelfCommand(t, l, s, TrayLockAction.lockAll) : null,
                  icon: const Icon(Icons.lock, size: 16),
                  label: const Text('Tümünü kilitle (k)'),
                ),
                OutlinedButton.icon(
                  onPressed: idle ? () => _shelfCommand(t, l, s, TrayLockAction.unlockAll) : null,
                  icon: const Icon(Icons.lock_open, size: 16),
                  label: const Text('Tümünü serbest bırak (x)'),
                ),
                if (_busy == shelfKey)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                if (reading != null) ...[
                  StatusIcon(status: reading.status, size: 16),
                  Text(reading.text, style: TextStyle(color: reading.status.color)),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 8 alanlık raf şeridi. Avadanlıklar fiziksel sırayla SAĞDAN SOLA dizilir:
  /// listedeki ilk avadanlık en sağdadır.
  Widget _shelfStrip(SerumTargetDef t, SerumLidDef l, SerumShelfLayout s, bool connected) {
    const height = 76.0;
    if (s.isOpenShelf) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: MedColors.border),
          borderRadius: MedRadius.mdAll,
        ),
        child: Text('Açık raf — kilit yok, testte yalnızca kapak açılır', style: hintStyle()),
      );
    }
    final ports = SerumRules.trayPorts(s);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (s.remainingArea > 0)
            Expanded(
              flex: s.remainingArea,
              child: Container(
                margin: const EdgeInsets.only(right: MedSpacing.xs),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: MedColors.border),
                  borderRadius: MedRadius.mdAll,
                ),
                child: Text(
                  s.trays.isEmpty ? 'Avadanlık ekleyin (8 alan)' : 'Boş · ${s.remainingArea} alan',
                  style: hintStyle(fontSize: 12),
                ),
              ),
            ),
          for (var i = s.trays.length - 1; i >= 0; i--)
            Expanded(
              flex: s.trays[i].size.areaSize,
              child: _trayTile(t, l, s, i, ports[i], connected),
            ),
        ],
      ),
    );
  }

  Widget _trayTile(SerumTargetDef t, SerumLidDef l, SerumShelfLayout s, int i, int port, bool connected) {
    final key = _trayKey(t, l, s, i);
    final reading = _readings[key];
    final idle = connected && _busy == null;
    final locked = s.isLocked;
    final colors = (reading?.status ?? (locked ? TestStatus.info : TestStatus.pending)).colors;
    return Container(
      margin: const EdgeInsets.only(left: MedSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.sm, vertical: MedSpacing.xs),
      decoration: BoxDecoration(
        color: reading == null ? MedColors.surface : colors.background,
        border: Border.all(color: reading == null ? MedColors.border : colors.border(alpha: 0.5)),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  SerumRules.sizeLabel(s.trays[i].size),
                  style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (locked) Text('port $port', style: monoStyle(fontSize: 11, color: MedColors.text3)),
                if (_busy == key)
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                else if (reading != null)
                  Text(
                    reading.text,
                    style: TextStyle(fontSize: 11, color: reading.status.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Avadanlık işlemleri',
            padding: EdgeInsets.zero,
            iconSize: 18,
            onSelected: (v) {
              switch (v) {
                case 'o':
                  _trayCommand(t, l, s, i, TrayLockAction.open);
                case 'c':
                  _trayCommand(t, l, s, i, TrayLockAction.cancel);
                case 's':
                  _trayCommand(t, l, s, i, TrayLockAction.status);
                case 't':
                  _trayCommand(t, l, s, i, TrayLockAction.keypadValue);
                case 'flow':
                  _runFlow(t, l, s, i);
                case 'remove':
                  _updateShelf(t, l, s.copyWith(trays: [...s.trays]..removeAt(i)));
              }
            },
            itemBuilder: (_) => [
              if (locked) ...[
                PopupMenuItem(value: 'flow', enabled: idle, child: const Text('Akış testi (kapak + kilit)')),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'o', enabled: idle, child: const Text('Kilidi aç (o)')),
                PopupMenuItem(value: 'c', enabled: idle, child: const Text('Açmayı iptal (c)')),
                PopupMenuItem(value: 's', enabled: idle, child: const Text('Durum (s)')),
                PopupMenuItem(value: 't', enabled: idle, child: const Text('Al-Ver tuş değeri (t)')),
                const PopupMenuDivider(),
              ],
              PopupMenuItem(value: 'remove', enabled: _busy == null, child: const Text('Avadanlığı kaldır')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flowPanel() {
    return Container(
      margin: const EdgeInsets.only(top: MedSpacing.xl),
      padding: const EdgeInsets.all(MedSpacing.lg),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Avadanlık akış testi', style: MedTextStyles.titleSm()),
              const Spacer(),
              if (_busy == _flowKey)
                TextButton.icon(
                  onPressed: () => setState(() => _flowCancel = true),
                  icon: const Icon(Icons.stop),
                  label: const Text('Durdur (kilitler serbest bırakılır)'),
                )
              else
                TextButton(onPressed: () => setState(() => _flowKey = null), child: const Text('Kapat')),
            ],
          ),
          for (final step in TrayFlowStep.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusIcon(status: _flow[step]?.$1 ?? TestStatus.pending, size: 16),
                  const SizedBox(width: MedSpacing.md),
                  SizedBox(width: 320, child: Text(step.label)),
                  Expanded(child: Text(_flow[step]?.$2 ?? '', style: TextStyle(color: MedColors.text2))),
                ],
              ),
            ),
          if (_flowLive != null && _flow[TrayFlowStep.waitTrayReturn]?.$1 == TestStatus.running)
            Padding(
              padding: const EdgeInsets.only(top: MedSpacing.sm),
              child: Row(
                children: [
                  StatusIcon(status: _flowLive!.status, size: 16),
                  const SizedBox(width: MedSpacing.md),
                  Text('Canlı: ${_flowLive!.text}', style: TextStyle(color: _flowLive!.status.color)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
