// Master çekmece — görsel test (#270).
//
// Taramadan (ya da client tanımından) gelen kübik ve birim doz çekmeceleri
// görsel olarak çizer; teknisyen bir göze dokununca açma / kapanma izlemesi
// kendiliğinden yapılır. Satır seçimi, ana kilidi açma ve çekilmesini
// bekleme gibi ön adımlar teknisyenden istenmez.
//
//   • Kübik    → satır = sıra kartı (`a`), sütun = göz (`tt`) — #267.
//                Ana kilit açık değilse önce açılır ve çekilmesi beklenir;
//                sonra :ZO → `ac` → `kp`. Teknisyen açılan kapağın görseldeki
//                göz olup olmadığını işaretler (kart/göz ↔ yerleşim eşlemesi).
//   • Birim doz → sütun = göz, satır = adım. Adres client'taki
//                `calculateAddressFromAssignment` ile hesaplanır.
//
// Her adım rapora yazılır; hücreler son sonucuna göre renklenir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/cabin_model.dart';
import '../../core/cabin_session.dart';
import '../../core/cubic_probe.dart';
import '../../core/drawer_flow.dart';
import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/common.dart';

/// Listede seçilebilen çekmece: kabin adresi + birim.
class _DrawerRef {
  const _DrawerRef(this.cabin, this.unit);

  final CabinInfo cabin;
  final CabinUnit unit;

  int get address => cabin.addressIndex;
  int get row => unit.row;
  bool get isCubic => unit.kind == UnitKind.kubik;
  String get key => '$address:$row';
  String get title => '${cabin.letter} · satır ${unit.rowLabel}';
}

/// Bir hücrenin son durumu.
class _CellState {
  const _CellState(this.status, this.text);

  final TestStatus status;
  final String text;
}

class DrawerVisualPage extends ConsumerStatefulWidget {
  const DrawerVisualPage({super.key});

  @override
  ConsumerState<DrawerVisualPage> createState() => _DrawerVisualPageState();
}

class _DrawerVisualPageState extends ConsumerState<DrawerVisualPage> {
  static const _drawerOpenTimeout = Duration(seconds: 10);
  static const _lidOpenTimeout = Duration(seconds: 5);
  static const _closeTimeout = Duration(seconds: 60);

  String? _selectedKey;

  /// Hücre durumları: '<çekmece>|<hücre>' → durum.
  final Map<String, _CellState> _cells = {};

  /// Kübikte bu ekrandan yeniden yoklanan gözler (çekmece anahtarı → gözler).
  final Map<String, List<CubicLidAddress>> _probed = {};

  /// Kübik ana kilit durumu (çekmece anahtarı → son okunan durum).
  final Map<String, DrawerPhysicalStatus> _master = {};

  /// Çalışan işlem (hücre anahtarı ya da 'probe' / 'master').
  String? _busy;
  String? _live;
  bool _cancel = false;

  /// Son açılan kübik göz: teknisyenin eşleme gözlemi bekleniyor.
  ({_DrawerRef drawer, CubicLidAddress lid})? _awaitingMapping;

  ICabinOperationService get _ops => ref.read(cabinOpsProvider);
  TestReport get _report => ref.read(testReportProvider);

  // ── Yardımcılar ────────────────────────────────────────────────

  static String _two(int v) => v.toString().padLeft(2, '0');

  String _cellKey(_DrawerRef d, String cell) => '${d.key}|$cell';

  void _setCell(_DrawerRef d, String cell, TestStatus status, String text) {
    if (!mounted) return;
    setState(() => _cells[_cellKey(d, cell)] = _CellState(status, text));
  }

  void _setLive(String? text) {
    if (mounted) setState(() => _live = text);
  }

  Future<void> _release(int address) async {
    try {
      await ref
          .read(serialServiceProvider)
          .sendAndReceive(
            CommandBuilder.buildManagementCommand(addressIndex: address, row: 0),
            timeout: const Duration(milliseconds: 300),
          );
    } catch (_) {}
  }

  /// [stream]'i [done] sağlanana, süre dolana ya da durdurulana kadar dinler.
  Future<T?> _await<T>(Stream<T> stream, bool Function(T) done, Duration timeout, {void Function(T)? onEvent}) async {
    final deadline = DateTime.now().add(timeout);
    await for (final v in stream) {
      onEvent?.call(v);
      if (done(v)) return v;
      if (_cancel || !mounted || DateTime.now().isAfter(deadline)) return null;
    }
    return null;
  }

  Future<void> _guard(String busyKey, Future<void> Function() body) async {
    if (_busy != null) return;
    setState(() {
      _busy = busyKey;
      _cancel = false;
      _awaitingMapping = null;
    });
    try {
      await body();
    } catch (e) {
      _report.add('Görsel test: hata', StepResult.fail, detail: e.toString());
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) {
        setState(() {
          _busy = null;
          _live = null;
        });
      }
    }
  }

  // ── Kübik ─────────────────────────────────────────────────────

  List<CubicLidAddress> _lidsOf(_DrawerRef d) {
    final probed = _probed[d.key];
    if (probed != null) return probed;
    if (d.unit.cubicLids.isNotEmpty) return d.unit.cubicLids;
    // Client tanımı: client'ın komut alanlarıyla aynı (a = compartmentNo,
    // tt = orderNo). Bu eşleme sahada henüz doğrulanmadı.
    return [
      for (final c in d.unit.cells)
        if (c.compartmentNo != null && c.orderNo != null) (card: c.compartmentNo!, lid: c.orderNo!),
    ]..sort((a, b) => a.card != b.card ? a.card.compareTo(b.card) : a.lid.compareTo(b.lid));
  }

  Future<void> _probe(_DrawerRef d) => _guard('probe', () async {
    _setLive('Gözler karttan yoklanıyor (sıra kartları 1–$cubicMaxCard × göz 01–${_two(cubicMaxLid)})…');
    final probe = await probeCubic(_ops, address: d.address, row: d.row);
    await _release(d.address);
    _report.add(
      'Görsel test — kübik yoklama (${d.title})',
      probe.lids.isEmpty ? StepResult.fail : StepResult.info,
      detail: describeCubicProbe(probe),
    );
    if (mounted) setState(() => _probed[d.key] = probe.lids);
  });

  /// Ana kilidi açar ve çekmecenin tam açılmasını bekler.
  Future<bool> _openMaster(_DrawerRef d) async {
    final manager = ManagementCard(addressIndex: d.address);
    final master = DrawerAddress.cubicMaster(d.row);
    _setLive('Çekmece ana kilidi açılıyor…');
    await _ops.openMasterDrawer(manager: manager, row: master.row, port: master.port, drawer: master.index);
    _setLive('Çekmeceyi ÇEKİN — tam açık (h3) bekleniyor…');
    final s = await _await<DrawerPhysicalStatus>(
      _ops.streamMasterDrawerStatus(manager: manager, row: master.row, port: master.port, drawer: master.index),
      (s) => s == DrawerPhysicalStatus.fullyOpen,
      _drawerOpenTimeout,
      onEvent: (s) {
        if (mounted) setState(() => _master[d.key] = s);
      },
    );
    final ok = s == DrawerPhysicalStatus.fullyOpen;
    _report.add(
      'Görsel test — ${d.title} ana kilit',
      ok ? StepResult.ok : StepResult.fail,
      detail: ok ? 'Çekmece tam açıldı (h3)' : 'Çekmece ${_drawerOpenTimeout.inSeconds} sn içinde tam açılmadı',
    );
    return ok;
  }

  Future<void> _openMasterOnly(_DrawerRef d) => _guard('master', () async {
    await _openMaster(d);
  });

  Future<void> _closeMaster(_DrawerRef d) => _guard('master', () async {
    final manager = ManagementCard(addressIndex: d.address);
    final master = DrawerAddress.cubicMaster(d.row);
    _setLive('Çekmeceyi KAPATIN — kilitli bekleniyor…');
    final s = await _await<DrawerPhysicalStatus>(
      _ops.streamMasterDrawerStatus(manager: manager, row: master.row, port: master.port, drawer: master.index),
      (s) => s == DrawerPhysicalStatus.locked,
      _closeTimeout,
      onEvent: (s) {
        if (mounted) setState(() => _master[d.key] = s);
      },
    );
    await _release(d.address);
    _report.add(
      'Görsel test — ${d.title} çekmece kapanışı',
      s == DrawerPhysicalStatus.locked ? StepResult.ok : StepResult.fail,
      detail: s == DrawerPhysicalStatus.locked ? 'Çekmece kilitlendi' : 'Çekmece kapanmadı / durduruldu',
    );
  });

  Future<void> _openLid(_DrawerRef d, CubicLidAddress lid) {
    final cell = 'k${lid.card}g${lid.lid}';
    final label = 'Kart ${lid.card} · göz ${_two(lid.lid)}';
    final frame = buildCubicFrame(DeviceAction.open, card: lid.card, lid: lid.lid);
    return _guard(cell, () async {
      final manager = ManagementCard(addressIndex: d.address);
      _setCell(d, cell, TestStatus.running, 'Başladı');

      if (_master[d.key] != DrawerPhysicalStatus.fullyOpen) {
        if (!await _openMaster(d)) {
          _setCell(d, cell, TestStatus.failed, 'Çekmece açılmadı');
          return;
        }
      }

      // Aç (ht → çekmece tam açık değil: bir kez daha; hz → kart cevap vermedi: iki kez daha).
      _setLive('$label açılıyor ($frame)…');
      String? failure;
      for (var attempt = 0; ; attempt++) {
        try {
          await openCubicLid(_ops, manager: manager, row: d.row, card: lid.card, lid: lid.lid);
          failure = null;
          break;
        } on CubicLidException catch (e) {
          final max = e.failure == CubicLidFailure.slaveNoResponse ? 2 : 1;
          failure = switch (e.failure) {
            CubicLidFailure.drawerNotOpen => 'çekmece tam açık değil (ht)',
            CubicLidFailure.slaveNoResponse => 'sıra kartı cevap vermedi (hz)',
            CubicLidFailure.protocolError => 'tanınmayan cevap (${e.detail?.trim() ?? '-'})',
            CubicLidFailure.noResponse => 'cevap yok',
          };
          if (attempt >= max || _cancel) break;
          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
      }
      if (failure != null) {
        _report.add('Görsel test — ${d.title} $label', StepResult.fail, detail: '$frame → $failure');
        _setCell(d, cell, TestStatus.failed, failure);
        return;
      }

      _setLive('$label: kapak açıldı mı (ac)…');
      var seenOpen = false;
      final opened = await _await<CubicLidStatus>(
        streamCubicLidStatus(_ops, manager: manager, row: d.row, card: lid.card, lid: lid.lid),
        (s) => s == CubicLidStatus.open,
        _lidOpenTimeout,
        onEvent: (s) => seenOpen |= s == CubicLidStatus.open,
      );
      if (opened == null && _cancel) {
        _setCell(d, cell, TestStatus.skipped, 'Durduruldu');
        return;
      }
      _setCell(d, cell, TestStatus.running, seenOpen ? 'Açık — kapatın' : 'Sensör açık görmedi — kapatın');
      if (mounted) setState(() => _awaitingMapping = (drawer: d, lid: lid));

      _setLive('$label: kapağı KAPATIN — kapalı (kp) bekleniyor…');
      final closed = await _await<CubicLidStatus>(
        streamCubicLidStatus(_ops, manager: manager, row: d.row, card: lid.card, lid: lid.lid),
        (s) {
          if (s == CubicLidStatus.open) seenOpen = true;
          return s == CubicLidStatus.closed && seenOpen;
        },
        _closeTimeout,
      );

      final (status, text) = switch ((seenOpen, closed != null)) {
        (true, true) => (TestStatus.passed, 'Açıldı, kapandı'),
        (true, false) => (TestStatus.warning, 'Açıldı, kapanış görülmedi'),
        (false, _) => (TestStatus.warning, 'Komut kabul edildi, sensör açık görmedi'),
      };
      _report.add(
        'Görsel test — ${d.title} $label',
        status == TestStatus.passed ? StepResult.ok : StepResult.fail,
        detail: '$frame → $text',
      );
      _setCell(d, cell, status, text);
    });
  }

  void _recordMapping(bool correct) {
    final m = _awaitingMapping;
    if (m == null) return;
    _report.add(
      'Görsel test — ${m.drawer.title} kart ${m.lid.card} · göz ${_two(m.lid.lid)} yerleşimi',
      correct ? StepResult.ok : StepResult.fail,
      detail: correct ? 'Görseldeki göz açıldı' : 'BAŞKA bir kapak açıldı — hangisi olduğunu rapora not edin',
    );
    setState(() => _awaitingMapping = null);
  }

  // ── Birim doz ─────────────────────────────────────────────────

  Future<void> _openUnitDose(_DrawerRef d, DrawerUnit unit, int step) {
    final compartment = unit.compartmentNo ?? 1;
    final cell = 'p${compartment}s$step';
    final config = d.unit.config;
    final mult = config?.stepMultiplier ?? 1;
    final index = (step * mult).clamp(1, 16);
    return _guard(cell, () async {
      // Port: client'ın atama üzerinden yaptığı hesap (ters port kuralı dahil).
      final full = config == null
          ? DrawerAddress(row: d.row, port: compartment, index: step)
          : clientAddress(row: d.row, config: config, cell: unit);
      final label = 'Göz $compartment · adım $step (port ${full.port} · ${_two(index)})';
      final manager = ManagementCard(addressIndex: d.address);
      _setCell(d, cell, TestStatus.running, 'Başladı');
      _setLive('$label açılıyor…');
      await _ops.openMasterDrawer(manager: manager, row: d.row, port: full.port, drawer: index);

      _setLive('$label: çekmeceyi ÇEKİN — açık (h3/h2) bekleniyor…');
      final pulled = await _await<DrawerPhysicalStatus>(
        _ops.streamMasterDrawerStatus(manager: manager, row: d.row, port: full.port, drawer: index),
        (s) => s == DrawerPhysicalStatus.fullyOpen || s == DrawerPhysicalStatus.halfOpen,
        _drawerOpenTimeout,
      );
      if (pulled == null) {
        await _release(d.address);
        final text = _cancel ? 'Durduruldu' : 'Çekmece açılmadı';
        _report.add('Görsel test — ${d.title} $label', StepResult.fail, detail: text);
        _setCell(d, cell, _cancel ? TestStatus.skipped : TestStatus.failed, text);
        return;
      }
      _setCell(d, cell, TestStatus.running, '${drawerStatusText(pulled)} — kapatın');

      _setLive('$label: çekmeceyi KAPATIN — kilitli bekleniyor…');
      final closed = await _await<DrawerPhysicalStatus>(
        _ops.streamMasterDrawerStatus(manager: manager, row: d.row, port: full.port, drawer: index),
        (s) => s == DrawerPhysicalStatus.locked,
        _closeTimeout,
      );
      await _release(d.address);
      final ok = closed != null;
      final text = ok ? 'Açıldı (${drawerStatusText(pulled)}), kapandı' : 'Açıldı, kapanış görülmedi';
      _report.add('Görsel test — ${d.title} $label', ok ? StepResult.ok : StepResult.fail, detail: text);
      _setCell(d, cell, ok ? TestStatus.passed : TestStatus.warning, text);
    });
  }

  // ── Ekran ─────────────────────────────────────────────────────

  List<_DrawerRef> _drawers(CabinSnapshot? snapshot) => [
    if (snapshot != null)
      for (final c in snapshot.cabins)
        for (final u in c.units)
          if (u.kind == UnitKind.kubik || u.kind == UnitKind.unitDose) _DrawerRef(c, u),
  ];

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(cabinSessionProvider);
    final connected = ref.watch(sessionProvider).port != null;
    final drawers = _drawers(session.active);
    final selected = drawers.where((d) => d.key == _selectedKey).firstOrNull ?? drawers.firstOrNull;

    if (drawers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: SectionCard(
          title: 'Çekmeceler',
          child: Text('Önce Kabin sayfasından kabini tarayın (ya da client tanımıyla devam edin).'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 260, child: SingleChildScrollView(child: _drawerList(drawers, selected))),
          const SizedBox(width: 16),
          Expanded(
            child: selected == null
                ? const SizedBox.shrink()
                : SingleChildScrollView(child: _drawerPanel(selected, connected)),
          ),
        ],
      ),
    );
  }

  Widget _drawerList(List<_DrawerRef> drawers, _DrawerRef? selected) {
    return SectionCard(
      title: 'Çekmeceler',
      child: Column(
        children: [
          for (final d in drawers)
            ListTile(
              dense: true,
              selected: d.key == selected?.key,
              selectedTileColor: MedColors.blue.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: MedRadius.mdAll),
              leading: Icon(d.isCubic ? Icons.grid_view : Icons.view_column_outlined),
              title: Text(d.title),
              subtitle: Text(
                '${d.unit.kind.label} · ${d.isCubic ? '${_lidsOf(d).length} göz' : '${d.unit.cells.length} göz'}'
                '${d.unit.problem != null ? '\n${d.unit.problem}' : ''}',
              ),
              onTap: _busy != null ? null : () => setState(() => _selectedKey = d.key),
            ),
        ],
      ),
    );
  }

  Widget _drawerPanel(_DrawerRef d, bool connected) {
    final canAct = connected && _busy == null;
    return SectionCard(
      title: '${d.title} — ${d.unit.name}',
      trailing: _busy != null
          ? TextButton.icon(
              onPressed: () => setState(() => _cancel = true),
              icon: const Icon(Icons.stop),
              label: const Text('Durdur'),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!connected) ...[const NotConnectedHint(), const SizedBox(height: 8)],
          if (_live != null) ...[
            Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 10),
                Expanded(child: Text(_live!, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (d.isCubic) _cubicPanel(d, canAct) else _unitDosePanel(d, canAct),
        ],
      ),
    );
  }

  Widget _cubicPanel(_DrawerRef d, bool canAct) {
    final lids = _lidsOf(d);
    final cards = (lids.map((l) => l.card).toSet().toList()..sort());
    final master = _master[d.key];
    final fromClient = _probed[d.key] == null && d.unit.cubicLids.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusBadge(
              status: master == DrawerPhysicalStatus.fullyOpen ? TestStatus.passed : TestStatus.pending,
              label: 'Ana kilit: ${master == null ? 'bilinmiyor' : drawerStatusText(master)}',
            ),
            OutlinedButton.icon(
              onPressed: canAct ? () => _openMasterOnly(d) : null,
              icon: const Icon(Icons.lock_open),
              label: const Text('Çekmeceyi aç'),
            ),
            OutlinedButton.icon(
              onPressed: canAct ? () => _closeMaster(d) : null,
              icon: const Icon(Icons.lock),
              label: const Text('Çekmeceyi kapat (bitir)'),
            ),
            OutlinedButton.icon(
              onPressed: canAct ? () => _probe(d) : null,
              icon: const Icon(Icons.radar),
              label: const Text('Gözleri karttan yokla'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          fromClient
              ? 'Gözler client tanımından (a = compartmentNo, tt = orderNo) — eşleme sahada doğrulanmadı; '
                    'emin olmak için "Gözleri karttan yokla".'
              : 'Satırlar sıra kartları (a), sütunlar o karttaki gözler (tt). Bir göze dokunun: ana kilit açık '
                    'değilse önce o açılır, sonra kapak açılır ve kapanması beklenir.',
          style: hintStyle(),
        ),
        const SizedBox(height: 12),
        if (lids.isEmpty)
          const Text('Göz bilgisi yok — "Gözleri karttan yokla".')
        else
          _drawerFrame(
            Column(
              children: [
                for (final card in cards)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(width: 64, child: Text('Kart $card', style: MedTextStyles.monoSm(color: MedColors.text2))),
                        for (final lid in lids.where((l) => l.card == card))
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _cellTile(
                                d,
                                'k${lid.card}g${lid.lid}',
                                title: 'Göz ${_two(lid.lid)}',
                                subtitle: buildCubicFrame(DeviceAction.open, card: lid.card, lid: lid.lid),
                                onTap: canAct ? () => _openLid(d, lid) : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (_awaitingMapping != null && _awaitingMapping!.drawer.key == d.key) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Kart ${_awaitingMapping!.lid.card} · göz ${_two(_awaitingMapping!.lid.lid)}: '
                'görseldeki göz mü açıldı?',
              ),
              ActionChip(label: const Text('Evet, doğru kapak'), onPressed: () => _recordMapping(true)),
              ActionChip(label: const Text('Hayır, başka kapak'), onPressed: () => _recordMapping(false)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _unitDosePanel(_DrawerRef d, bool canAct) {
    final units = [...d.unit.cells]..sort((a, b) => (a.compartmentNo ?? 0).compareTo(b.compartmentNo ?? 0));
    final steps = (d.unit.config?.numberOfSteps ?? 1).clamp(1, 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          d.unit.config == null
              ? 'Çekmece tanımı yok: port = göz no, adım çarpanı 1 varsayıldı.'
              : 'Sütunlar gözler, satırlar adımlar (en üst = en açık). Bir adıma dokunun: göz o adıma kadar açılır, '
                    'çekilmesi ve kapanması beklenir.',
          style: hintStyle(),
        ),
        const SizedBox(height: 12),
        if (units.isEmpty)
          const Text('Göz bilgisi yok.')
        else
          _drawerFrame(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final u in units)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Column(
                        children: [
                          Text('Göz ${u.compartmentNo ?? '?'}', style: MedTextStyles.monoSm(color: MedColors.text2)),
                          const SizedBox(height: 4),
                          for (var step = steps; step >= 1; step--)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _cellTile(
                                d,
                                'p${u.compartmentNo ?? 1}s$step',
                                title: 'Adım $step',
                                onTap: canAct ? () => _openUnitDose(d, u, step) : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _drawerFrame(Widget child) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFDCE8F5),
      border: Border.all(color: const Color(0xFFA8BEDB), width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: child,
  );

  Widget _cellTile(_DrawerRef d, String cell, {required String title, String? subtitle, VoidCallback? onTap}) {
    final state = _cells[_cellKey(d, cell)];
    final running = _busy == cell;
    final status = running ? TestStatus.running : (state?.status ?? TestStatus.pending);
    final colors = status.colors;
    return Material(
      color: state == null && !running ? MedColors.surface : colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: MedRadius.mdAll,
        side: BorderSide(color: running ? MedColors.blue : MedColors.border, width: running ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: MedRadius.mdAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
                    if (state != null || running) Icon(status.icon, size: 16, color: status.color),
                  ],
                ),
                if (subtitle != null) Text(subtitle, style: MedTextStyles.monoXs(color: MedColors.text3)),
                const Spacer(),
                if (state != null)
                  Text(state.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: status.color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
