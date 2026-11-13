import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/common.dart';

// Serum avadanlık elektromanyetik kilitleri — #217, #221.
//
// Kilit kartı aynı RS485 hattında, kendi protokolüyle konuşur:
//   komut <iXX:YZ>  (XX kart ID 01-99, Y port 1-8, Z komut)  →  yanıt /xxxx\
//   k: tüm kilitleri enerjile (sabitle)    x: tümünü serbest bırak
//   o: portu aç (diğerlerini kart kilitler) c: açmayı iptal et
//   s: portun İŞLEM durumu   t: Al-Ver tuş değeri
//
// ÖNEMLİ (#221 saha): `s` kilidin FİZİKSEL durumunu değil kartın o porttaki
// işlem durumunu döner. k/x sonrası kart her zaman "boşta" (s:03) döner —
// kilitlerin enerjili/serbest olduğu `s` ile görülemez. Bu yüzden ekranda
// son kart geneli komutu (k/x) ayrıca gösterilir ve `o` sonrası teknisyen
// fiziksel sonucu işaretler.
//
// OLMASI GEREKEN AKIŞ: kilitler normalde serbest (x); serum kapağı açılınca
// tümü enerjilenir (k), yalnız hedef avadanlık açılır (o); avadanlık yerine
// itilip kapak kapanınca yeniden serbest (x).

class TrayLockSection extends ConsumerStatefulWidget {
  const TrayLockSection({super.key, required this.address, required this.row, required this.idle});

  /// Yönetim kartı adresi (1 = A).
  final int address;

  /// Serum kartının satırı (bağımsız serum kabininde 26). null → kapak adımları kapalı.
  final int? row;

  /// Üst sayfada başka bir işlem sürmüyor.
  final bool idle;

  @override
  ConsumerState<TrayLockSection> createState() => _TrayLockSectionState();
}

// ── Kart yanıtının okunur hali ──────────────────────────────────────

/// Bir kart yanıtının ekranda gösterilecek hali.
class _Reading {
  const _Reading(this.tone, this.title, [this.note]);

  /// Renk ve ikon tonu (pharmed_ui ortak durum renkleri).
  final MedTone tone;
  final String title;
  final String? note;

  static _Reading of(TrayLockResponse r, {int? port}) {
    final p = port == null ? '' : 'Port $port: ';
    return switch (r) {
      TrayLockOk() => const _Reading(MedTone.success, 'Komut kabul edildi (okkk)'),
      TrayLockStatusResponse(:final status) => switch (status) {
        TrayLockStatus.unlocked => _Reading(
          MedTone.warning,
          '${p}kart kilidi AÇTI, avadanlık henüz çekilmedi (s:01)',
          'Avadanlık fiziksel olarak serbest değilse kilit kartın komutuna uymuyor demektir.',
        ),
        TrayLockStatus.pulled => _Reading(MedTone.info, '${p}avadanlık ÇEKİLDİ (s:02)'),
        TrayLockStatus.idle => _Reading(
          MedTone.neutral,
          '${p}kart boşta — bu portta açma işlemi yok (s:03)',
          's:03 kilidin fiziksel durumunu göstermez. k / x sonrası kart her zaman boşta döner; '
              'kilitlerin enerjili mi serbest mi olduğu için "Kart geneli" satırına bakın.',
        ),
      },
      TrayLockKeypadResponse(:final value) => _Reading(MedTone.info, '${p}Al-Ver tuş değeri: $value'),
      TrayLockErrorResponse(:final failure) => _Reading(MedTone.error, '$p${_failureText(failure)}'),
    };
  }

  static String _failureText(TrayLockFailure f) => switch (f) {
    TrayLockFailure.invalidDeviceId => 'Geçersiz kart ID (noo1)',
    TrayLockFailure.trayOpen => 'Bir avadanlık çekili — önce yerine itin (noo2)',
    TrayLockFailure.invalidPort => 'Geçersiz port (noo3)',
    TrayLockFailure.busy => 'Kart meşgul — başka port açık (noo4)',
    TrayLockFailure.alreadyPulled => 'Avadanlık zaten çekildi, iptal edilemez (noo5)',
    TrayLockFailure.unknownCommand => 'Kart komutu tanımadı (noo6)',
    TrayLockFailure.noResponse => 'Kart cevap vermedi',
    TrayLockFailure.protocolError => 'Tanınmayan yanıt',
  };

  Color get color => MedSemanticColors.of(tone).foreground;

  IconData get icon => switch (tone) {
    MedTone.success => Icons.check_circle,
    MedTone.warning => Icons.lock_open,
    MedTone.info => Icons.info,
    MedTone.neutral => Icons.radio_button_unchecked,
    MedTone.error => Icons.error,
  };
}

/// Yanıtı renkli, açıklamalı bir kutu olarak gösterir.
class _ReadingTile extends StatelessWidget {
  const _ReadingTile({required this.reading, this.raw, this.label});

  final _Reading reading;
  final String? raw;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = reading.color;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.07),
        border: Border.all(color: c.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(reading.icon, size: 18, color: c),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label == null ? reading.title : '$label — ${reading.title}',
                  style: TextStyle(fontWeight: FontWeight.w600, color: c),
                ),
                if (reading.note != null)
                  Text(reading.note!, style: TextStyle(fontSize: 12, color: MedColors.text2)),
                if (raw != null)
                  Text(
                    'Ham: $raw',
                    style: monoStyle(fontSize: 11, color: MedColors.text3),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Akış adımları ───────────────────────────────────────────────────

enum _FlowStep { releaseAll, openLid, waitLidOpen, lockAll, openTray, waitTrayReturn, waitLidClose, releaseAtEnd }

extension on _FlowStep {
  String get label => switch (this) {
    _FlowStep.releaseAll => 'Başlangıç: tüm kilitler serbest (x)',
    _FlowStep.openLid => 'Serum kapağını aç',
    _FlowStep.waitLidOpen => 'Kapağın açıldığını bekle',
    _FlowStep.lockAll => 'Tüm kilitleri enerjile (k)',
    _FlowStep.openTray => 'Hedef avadanlığı aç (o)',
    _FlowStep.waitTrayReturn => 'Avadanlığın çekilip yerine itilmesini bekle',
    _FlowStep.waitLidClose => 'Kapağın kapanmasını bekle',
    _FlowStep.releaseAtEnd => 'Bitiş: tüm kilitler serbest (x)',
  };
}

/// `o` sonrası teknisyenin fiziksel gözlemi.
const _observations = [
  ('Yalnız hedef serbest (doğru)', true),
  ('Hedef kilitli, diğerleri kilitli', false),
  ('Hedef kilitli, diğerleri SERBEST (ters)', false),
  ('Hepsi serbest', false),
];

class _TrayLockSectionState extends ConsumerState<TrayLockSection> {
  final _deviceCtrl = TextEditingController(text: '1');
  int _port = 1;
  int _lid = 1;

  bool _busy = false;

  // Son komut
  String? _lastLabel;
  String? _lastRaw;
  _Reading? _lastReading;

  /// Son başarılı kart geneli komut: 'k' (enerjili), 'x' (serbest) ya da null.
  String? _cardMode;

  /// `o` sonrası fiziksel gözlem bekleyen port.
  int? _awaitingObservation;

  // Kart ID taraması
  List<int>? _foundDevices;

  // Port tablosu (1–8 durum)
  Map<int, (String?, TrayLockResponse)>? _portTable;

  // Canlı durum
  Timer? _watch;
  bool _polling = false;
  _Reading? _liveReading;
  int? _liveKeypad;

  // Akış testi
  bool _flowRunning = false;
  bool _flowCancel = false;
  final Map<_FlowStep, (StepResult, String)> _flow = {};
  _FlowStep? _flowCurrent;

  int? get _deviceId {
    final v = int.tryParse(_deviceCtrl.text.trim());
    return v != null && v >= TrayLockProtocol.minDeviceId && v <= TrayLockProtocol.maxDeviceId ? v : null;
  }

  ISerialCommunicationService get _serial => ref.read(serialServiceProvider);

  @override
  void dispose() {
    _watch?.cancel();
    _flowCancel = true;
    _deviceCtrl.dispose();
    super.dispose();
  }

  // ── Kilit kartı komutları ──────────────────────────────────────

  Future<(String?, TrayLockResponse)> _tray(int deviceId, TrayLockAction action, {int? port, Duration? timeout}) async {
    final cmd = TrayLockProtocol.build(deviceId: deviceId, action: action, port: port);
    String? raw;
    try {
      raw = await _serial.sendAndReceive(cmd, timeout: timeout ?? const Duration(milliseconds: 1000));
    } catch (_) {
      raw = null;
    }
    final res = TrayLockProtocol.parse(raw);
    if (res is TrayLockOk && action.isCardWide && mounted) {
      setState(() => _cardMode = action == TrayLockAction.lockAll ? 'k' : 'x');
    }
    return (raw?.trim(), res);
  }

  static String _actionLabel(TrayLockAction a) => switch (a) {
    TrayLockAction.lockAll => 'Tümünü kilitle (k)',
    TrayLockAction.unlockAll => 'Tümünü serbest bırak (x)',
    TrayLockAction.open => 'Portu aç (o)',
    TrayLockAction.cancel => 'Açmayı iptal (c)',
    TrayLockAction.status => 'Durum (s)',
    TrayLockAction.keypadValue => 'Tuş değeri (t)',
  };

  Future<void> _manual(TrayLockAction action) async {
    final deviceId = _deviceId;
    if (deviceId == null) return showMessage(context, 'Kart ID 1–99 olmalı.', error: true);
    final port = action.isCardWide ? null : _port;
    setState(() => _busy = true);
    final (raw, res) = await _tray(deviceId, action, port: port);
    final reading = _Reading.of(res, port: port);
    final label = 'Kart $deviceId · ${_actionLabel(action)}${port == null ? '' : ' · port $port'}';
    ref
        .read(testReportProvider)
        .add(
          label,
          res is TrayLockErrorResponse ? StepResult.fail : StepResult.info,
          detail: '${raw ?? '(cevap yok)'} → ${reading.title}',
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastLabel = label;
      _lastRaw = raw ?? '(cevap yok)';
      _lastReading = reading;
      _awaitingObservation = action == TrayLockAction.open && res is TrayLockOk ? port : null;
    });
  }

  void _observe(String what, bool correct) {
    final port = _awaitingObservation;
    if (port == null) return;
    ref
        .read(testReportProvider)
        .add(
          'Gözlem: kart ${_deviceCtrl.text} · o port $port → $what',
          correct ? StepResult.ok : StepResult.fail,
          detail: 'Kart geneli son komut: ${_cardModeText()}',
        );
    setState(() => _awaitingObservation = null);
  }

  String _cardModeText() => switch (_cardMode) {
    'k' => 'tüm kilitler ENERJİLİ (k)',
    'x' => 'tüm kilitler SERBEST (x)',
    _ => 'bilinmiyor (bu oturumda k/x gönderilmedi)',
  };

  Future<void> _scanDevices() async {
    setState(() {
      _busy = true;
      _foundDevices = null;
    });
    final found = <int>[];
    for (var id = 1; id <= 16; id++) {
      final (_, res) = await _tray(id, TrayLockAction.status, port: 1, timeout: const Duration(milliseconds: 300));
      if (res is! TrayLockErrorResponse || res.failure != TrayLockFailure.noResponse) found.add(id);
      if (!mounted) return;
    }
    ref
        .read(testReportProvider)
        .add(
          'Kilit kartı ID taraması (1–16)',
          found.isEmpty ? StepResult.fail : StepResult.info,
          detail: 'Cevap veren kart ID\'leri: ${found.isEmpty ? '-' : found.join(', ')}',
        );
    setState(() {
      _busy = false;
      _foundDevices = found;
      if (found.isNotEmpty) _deviceCtrl.text = '${found.first}';
    });
  }

  Future<void> _queryAllPorts() async {
    final deviceId = _deviceId;
    if (deviceId == null) return showMessage(context, 'Kart ID 1–99 olmalı.', error: true);
    setState(() => _busy = true);
    final table = <int, (String?, TrayLockResponse)>{};
    for (var p = 1; p <= TrayLockProtocol.maxPort; p++) {
      table[p] = await _tray(deviceId, TrayLockAction.status, port: p);
      if (!mounted) return;
    }
    ref
        .read(testReportProvider)
        .add(
          'Kart $deviceId · tüm portların durumu',
          StepResult.info,
          detail: [
            'Kart geneli: ${_cardModeText()}',
            for (final e in table.entries)
              'Port ${e.key}: ${e.value.$1 ?? '(cevap yok)'} → ${_Reading.of(e.value.$2).title}',
          ].join('\n'),
        );
    setState(() {
      _busy = false;
      _portTable = table;
    });
  }

  void _toggleWatch() {
    if (_watch != null) {
      _watch?.cancel();
      setState(() => _watch = null);
      return;
    }
    final deviceId = _deviceId;
    if (deviceId == null) return;
    final port = _port;
    _watch = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (_polling || !mounted) return;
      _polling = true;
      try {
        final (_, s) = await _tray(deviceId, TrayLockAction.status, port: port);
        final (_, t) = await _tray(deviceId, TrayLockAction.keypadValue, port: port);
        if (!mounted) return;
        setState(() {
          _liveReading = _Reading.of(s, port: port);
          _liveKeypad = t is TrayLockKeypadResponse ? t.value : null;
        });
      } finally {
        _polling = false;
      }
    });
    setState(() {});
  }

  // ── Serum kapağı (T protokolü, port = kapak no) ────────────────

  Future<bool> _selectRow(int row) async {
    try {
      final r = await _serial.sendAndReceive(
        CommandBuilder.buildManagementCommand(addressIndex: widget.address, row: row),
        timeout: const Duration(milliseconds: 800),
      );
      return r != null && r.contains('ok');
    } catch (_) {
      return false;
    }
  }

  /// Kapağın ham durumu (`h3`, `h6` …) ya da null.
  Future<String?> _lidStatus(int row, int lid) async {
    if (!await _selectRow(row)) return null;
    try {
      final raw = await _serial.sendAndReceive(
        CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: lid, drawer: 0),
        timeout: const Duration(milliseconds: 400),
      );
      return raw == null ? null : RegExp(r'\.([^,]*),').firstMatch(raw)?.group(1);
    } catch (_) {
      return null;
    }
  }

  static bool _lidIsOpen(String? s) => s == 'h1' || s == 'h2' || s == 'h3' || s == 'h6';
  static bool _lidIsClosed(String? s) => s == 'h0' || s == 'h4' || s == 'h5';

  // ── Akış testi ─────────────────────────────────────────────────

  void _mark(_FlowStep step, StepResult result, String detail) {
    ref.read(testReportProvider).add('Kilit akışı — ${step.label}', result, detail: detail);
    if (mounted) setState(() => _flow[step] = (result, detail));
  }

  /// [condition] sağlanana kadar [interval] aralıkla dener. Süre dolarsa ya da
  /// iptal edilirse false.
  Future<bool> _waitUntil(Future<bool> Function() condition, Duration timeout, {Duration? interval}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (_flowCancel || !mounted) return false;
      if (await condition()) return true;
      await Future<void>.delayed(interval ?? const Duration(milliseconds: 500));
    }
    return false;
  }

  Future<void> _runFlow() async {
    final row = widget.row;
    final deviceId = _deviceId;
    if (row == null || deviceId == null) {
      return showMessage(context, 'Satır (bölüm 1) ve kart ID gerekli.', error: true);
    }
    final lid = _lid;
    final port = _port;
    _watch?.cancel();
    setState(() {
      _watch = null;
      _flowRunning = true;
      _flowCancel = false;
      _flow.clear();
      _liveReading = null;
    });
    ref
        .read(testReportProvider)
        .add(
          'Kilit akışı başladı',
          StepResult.info,
          detail: 'Kapak $lid (satır $row) · kilit kartı $deviceId · avadanlık portu $port',
        );

    Future<bool> step(_FlowStep s, Future<(bool, String)> Function() body) async {
      if (_flowCancel || !mounted) return false;
      setState(() => _flowCurrent = s);
      final (ok, detail) = await body();
      _mark(s, ok ? StepResult.ok : StepResult.fail, detail);
      return ok;
    }

    Future<(bool, String)> trayCmd(TrayLockAction a, {int? p}) async {
      final (raw, res) = await _tray(deviceId, a, port: p);
      return (res is TrayLockOk, '${raw ?? '(cevap yok)'} → ${_Reading.of(res, port: p).title}');
    }

    var ok =
        await step(_FlowStep.releaseAll, () => trayCmd(TrayLockAction.unlockAll)) &&
        await step(_FlowStep.openLid, () async {
          try {
            await ref
                .read(cabinOpsProvider)
                .openMasterSerumDrawer(manager: ManagementCard(addressIndex: widget.address), row: row, port: lid);
            return (true, 'Kapak $lid için açma komutu kabul edildi');
          } catch (e) {
            // [#221] Kapak zaten açıksa kart `.no` döner — durumu sorgula.
            final status = await _lidStatus(row, lid);
            if (_lidIsOpen(status)) return (true, 'Kapak $lid zaten açıktı ($status) — açma komutu .no döndü');
            return (false, 'HATA: $e');
          }
        }) &&
        await step(_FlowStep.waitLidOpen, () async {
          String? last;
          final opened = await _waitUntil(() async {
            last = await _lidStatus(row, lid);
            return _lidIsOpen(last);
          }, const Duration(seconds: 15));
          return (opened, 'Son kapak durumu: ${last ?? '(cevap yok)'}');
        }) &&
        await step(_FlowStep.lockAll, () => trayCmd(TrayLockAction.lockAll)) &&
        await step(_FlowStep.openTray, () => trayCmd(TrayLockAction.open, p: port)) &&
        await step(_FlowStep.waitTrayReturn, () async {
          var seenActive = false;
          var seenPulled = false;
          var last = '-';
          final returned = await _waitUntil(() async {
            final (_, res) = await _tray(deviceId, TrayLockAction.status, port: port);
            final reading = _Reading.of(res, port: port);
            last = reading.title;
            if (mounted) setState(() => _liveReading = reading);
            if (res case TrayLockStatusResponse(:final status)) {
              if (status != TrayLockStatus.idle) seenActive = true;
              if (status == TrayLockStatus.pulled) seenPulled = true;
              return seenActive && status == TrayLockStatus.idle;
            }
            return false;
          }, const Duration(seconds: 90));
          final detail = returned
              ? (seenPulled
                    ? 'Avadanlık çekildi ve yerine itildi'
                    : 'Kart boşa döndü ama "çekildi" (s:02) hiç görülmedi')
              : (seenActive ? 'Avadanlık yerine itilmedi — son: $last' : 'Kart kilidi hiç açmadı — son: $last');
          return (returned, detail);
        }) &&
        await step(_FlowStep.waitLidClose, () async {
          String? last;
          final closed = await _waitUntil(() async {
            last = await _lidStatus(row, lid);
            return _lidIsClosed(last);
          }, const Duration(seconds: 90));
          return (closed, 'Son kapak durumu: ${last ?? '(cevap yok)'}');
        });

    // Bitişte (başarılı ya da yarıda kalsa da) kilitler serbest bırakılır.
    _flowCancel = false;
    final release = await step(_FlowStep.releaseAtEnd, () => trayCmd(TrayLockAction.unlockAll));
    ok = ok && release;
    await _selectRow(0);

    ref
        .read(testReportProvider)
        .add('Kilit akışı ${ok ? 'tamamlandı' : 'yarıda kaldı'}', ok ? StepResult.ok : StepResult.fail);
    if (!mounted) return;
    setState(() {
      _flowRunning = false;
      _flowCurrent = null;
    });
  }

  // ── UI ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(sessionProvider.select((s) => s.port != null));
    final free = connected && widget.idle && !_busy && !_flowRunning;
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    return SectionCard(
      title: '5. Avadanlık kilitleri (elektromanyetik)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Olması gereken: kilitler normalde serbest; kapak açılınca tümü enerjilenir (k), yalnız işlem '
            'yapılacak avadanlık açılır (o); bitince yeniden serbest (x). Kart ID = rafın kilit kartı, '
            'port = avadanlığın kart üzerindeki portu (en sağdan 1).',
          ),
          const SizedBox(height: 12),

          // ── Kart ve port ────────────────────────────────────────
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NumberField(label: 'Kart ID', controller: _deviceCtrl, width: 90),
              const Text('Port:'),
              DropdownButton<int>(
                value: _port,
                items: [for (var p = 1; p <= 8; p++) DropdownMenuItem(value: p, child: Text('$p'))],
                onChanged: free ? (v) => setState(() => _port = v ?? _port) : null,
              ),
              BusyButton(
                label: 'Kart ID bul (1–16)',
                icon: Icons.search,
                busy: _busy && _foundDevices == null,
                onPressed: free ? _scanDevices : null,
              ),
              if (_foundDevices != null)
                Text('Bulunan: ${_foundDevices!.isEmpty ? '-' : _foundDevices!.join(', ')}'),
            ],
          ),
          const SizedBox(height: 8),
          _ReadingTile(
            label: 'Kart geneli',
            reading: _Reading(
              switch (_cardMode) {
                'k' => MedTone.warning,
                'x' => MedTone.success,
                _ => MedTone.neutral,
              },
              _cardModeText(),
              'Kartın `s` cevabı bunu göstermez; son başarılı k / x komutundan izlenir.',
            ),
          ),

          // ── Elle komut ─────────────────────────────────────────
          const SizedBox(height: 16),
          Text('Elle komut', style: titleStyle),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final action in TrayLockAction.values)
                OutlinedButton(onPressed: free ? () => _manual(action) : null, child: Text(_actionLabel(action))),
              OutlinedButton.icon(
                onPressed: free ? _queryAllPorts : null,
                icon: const Icon(Icons.table_rows),
                label: const Text('Tüm portları sorgula (1–8)'),
              ),
              OutlinedButton.icon(
                onPressed: connected && !_flowRunning && _deviceId != null ? _toggleWatch : null,
                icon: Icon(_watch != null ? Icons.visibility_off : Icons.visibility),
                label: Text(_watch != null ? 'İzlemeyi durdur' : 'Canlı durum (0,5 sn)'),
              ),
            ],
          ),
          if (_lastReading != null) _ReadingTile(label: _lastLabel, reading: _lastReading!, raw: _lastRaw),
          if (_awaitingObservation != null) ...[
            const SizedBox(height: 8),
            Text('Port $_awaitingObservation açıldı. Fiziksel olarak ne oldu?'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (label, correct) in _observations)
                  ActionChip(label: Text(label), onPressed: () => _observe(label, correct)),
              ],
            ),
          ],
          if (_watch != null && _liveReading != null)
            _ReadingTile(
              label: 'Canlı${_liveKeypad != null ? ' · tuş $_liveKeypad' : ''}',
              reading: _liveReading!,
            ),
          if (_portTable != null) ...[
            const SizedBox(height: 10),
            Text('Port durumları (kart ${_deviceCtrl.text})', style: titleStyle),
            for (final e in _portTable!.entries)
              _ReadingTile(reading: _Reading.of(e.value.$2, port: e.key), raw: e.value.$1 ?? '(cevap yok)'),
          ],

          // ── Akış testi ─────────────────────────────────────────
          const Divider(height: 28),
          Text('Akış testi (olması gereken çalışma prensibi)', style: titleStyle),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Serum kapağı:'),
              DropdownButton<int>(
                value: _lid,
                items: [
                  for (var l = 1; l <= DeviceConstants.maxSerumLids; l++)
                    DropdownMenuItem(value: l, child: Text('Kapak $l')),
                ],
                onChanged: free ? (v) => setState(() => _lid = v ?? _lid) : null,
              ),
              Text('Satır: ${widget.row ?? '— (bölüm 1)'}  ·  Kart ${_deviceCtrl.text}  ·  Port $_port'),
              BusyButton(
                label: 'Akışı başlat',
                icon: Icons.play_arrow,
                busy: _flowRunning,
                onPressed: free && widget.row != null ? _runFlow : null,
              ),
              if (_flowRunning)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _flowCancel = true),
                  icon: const Icon(Icons.stop),
                  label: const Text('Durdur (kilitler serbest bırakılır)'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final s in _FlowStep.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: _flowCurrent == s && _flowRunning
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : StatusIcon(status: _flow[s]?.$1.status ?? TestStatus.pending, size: 16),
                  ),
                  SizedBox(width: 300, child: Text(s.label)),
                  Expanded(child: Text(_flow[s]?.$2 ?? '', style: TextStyle(color: MedColors.text2))),
                ],
              ),
            ),
          if (_flowRunning && _flowCurrent == _FlowStep.waitTrayReturn && _liveReading != null)
            _ReadingTile(label: 'Canlı', reading: _liveReading!),
        ],
      ),
    );
  }
}
