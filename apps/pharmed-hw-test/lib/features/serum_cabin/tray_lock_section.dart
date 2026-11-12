import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/common.dart';

// Serum avadanlık elektromanyetik kilitleri — issue #217.
//
// Kilit kartı aynı RS485 hattında, kendi protokolüyle konuşur:
//   komut <iXX:YZ>  (XX kart ID 01-99, Y port 1-8, Z komut)  →  yanıt /xxxx\
//   k: tüm kilitleri enerjile (sabitle)    x: tümünü serbest bırak
//   o: portu aç (diğerlerini kart kilitler) c: açmayı iptal et
//   s: port durumu (s:01 açıldı, s:02 çekildi, s:03 kapalı)   t: Al-Ver tuş değeri
//
// OLMASI GEREKEN AKIŞ (sahadan gelen kural):
//   Kilitler normalde SERBEST (x). Serum kapağı açılınca tüm kilitler
//   enerjilenir (k), yalnız işlem yapılacak avadanlık açılır (o). Avadanlık
//   yerine itilip kapak kapanınca kilitler yeniden serbest bırakılır (x).
//
// Bu bölüm: (1) elle komut, (2) kart ID taraması, (3) akışın adım adım testi.

/// Kapak durumu sorgusu ve açma için üst sayfanın sağladığı bağlam.
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

class _TrayLockSectionState extends ConsumerState<TrayLockSection> {
  final _deviceCtrl = TextEditingController(text: '1');
  int _port = 1;
  int _lid = 1;

  bool _busy = false;
  String? _lastResult;

  // Kart ID taraması
  List<int>? _foundDevices;

  // Canlı durum
  Timer? _watch;
  bool _polling = false;
  String? _liveStatus;
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
    return (raw, TrayLockProtocol.parse(raw));
  }

  static String _describe(TrayLockResponse r) => switch (r) {
    TrayLockOk() => 'ok',
    TrayLockStatusResponse(:final status) => switch (status) {
      TrayLockStatus.unlocked => 's:01 kilit açıldı (çekilmedi)',
      TrayLockStatus.pulled => 's:02 avadanlık çekildi',
      TrayLockStatus.idle => 's:03 kapalı / boşta',
    },
    TrayLockKeypadResponse(:final value) => 'tuş değeri $value',
    TrayLockErrorResponse(:final failure) => 'HATA: ${failure.name}',
  };

  Future<void> _manual(TrayLockAction action) async {
    final deviceId = _deviceId;
    if (deviceId == null) return showMessage(context, 'Kart ID 1–99 olmalı.', error: true);
    setState(() => _busy = true);
    final (raw, res) = await _tray(deviceId, action, port: action.isCardWide ? null : _port);
    final text = '${raw?.trim() ?? '(cevap yok)'} → ${_describe(res)}';
    ref
        .read(testReportProvider)
        .add(
          'Kilit kartı ${action.code} (kart $deviceId${action.isCardWide ? '' : ', port $_port'})',
          res is TrayLockErrorResponse ? StepResult.fail : StepResult.info,
          detail: text,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastResult = text;
    });
  }

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
          _liveStatus = _describe(s);
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
      return (res is TrayLockOk, '${raw?.trim() ?? '(cevap yok)'} → ${_describe(res)}');
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
          String last = '-';
          final returned = await _waitUntil(() async {
            final (_, res) = await _tray(deviceId, TrayLockAction.status, port: port);
            last = _describe(res);
            if (mounted) setState(() => _liveStatus = last);
            if (res case TrayLockStatusResponse(:final status)) {
              if (status != TrayLockStatus.idle) seenActive = true;
              return seenActive && status == TrayLockStatus.idle;
            }
            return false;
          }, const Duration(seconds: 90));
          return (
            returned,
            returned
                ? 'Avadanlık açıldı ve yerine itildi'
                : (seenActive ? 'Avadanlık yerine itilmedi (son: $last)' : 'Kilit hiç açılmadı (son: $last)'),
          );
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
    const mono = TextStyle(fontFamily: 'Consolas', fontSize: 12);

    return SectionCard(
      title: '5. Avadanlık kilitleri (elektromanyetik)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kilit kartı aynı hattaki <iXX:YZ> protokolüyle konuşur. Kart ID = rafın kilit kartı, '
            'port = avadanlığın kart üzerindeki portu (1–8). Olması gereken: kilitler normalde serbest; '
            'kapak açılınca tümü enerjilenir, yalnız işlem yapılacak avadanlık açılır; bitince yeniden serbest.',
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          Text('Elle komut', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (action, label) in const [
                (TrayLockAction.lockAll, 'Tümünü kilitle (k)'),
                (TrayLockAction.unlockAll, 'Tümünü serbest bırak (x)'),
                (TrayLockAction.open, 'Portu aç (o)'),
                (TrayLockAction.cancel, 'Açmayı iptal (c)'),
                (TrayLockAction.status, 'Durum (s)'),
                (TrayLockAction.keypadValue, 'Tuş değeri (t)'),
              ])
                OutlinedButton(onPressed: free ? () => _manual(action) : null, child: Text(label)),
              OutlinedButton.icon(
                onPressed: connected && !_flowRunning && _deviceId != null ? _toggleWatch : null,
                icon: Icon(_watch != null ? Icons.visibility_off : Icons.visibility),
                label: Text(_watch != null ? 'İzlemeyi durdur' : 'Canlı durum (0,5 sn)'),
              ),
            ],
          ),
          if (_lastResult != null) ...[const SizedBox(height: 6), Text(_lastResult!, style: mono)],
          if (_watch != null || _liveStatus != null) ...[
            const SizedBox(height: 4),
            Text(
              'Canlı: ${_liveStatus ?? '—'}${_liveKeypad != null ? ' · tuş $_liveKeypad' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          const Divider(height: 28),
          Text('Akış testi (olması gereken çalışma prensibi)', style: Theme.of(context).textTheme.titleSmall),
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
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: _flowCurrent == s && _flowRunning
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(
                            _flow[s] == null
                                ? Icons.radio_button_unchecked
                                : (_flow[s]!.$1 == StepResult.ok ? Icons.check_circle : Icons.cancel),
                            size: 16,
                            color: _flow[s] == null
                                ? Colors.grey
                                : (_flow[s]!.$1 == StepResult.ok ? Colors.green : Colors.red),
                          ),
                  ),
                  SizedBox(width: 300, child: Text(s.label)),
                  Expanded(child: Text(_flow[s]?.$2 ?? '', style: mono)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
