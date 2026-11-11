import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/address_picker.dart';
import '../../widgets/common.dart';

/// Çekmece `S` cevap kodları (docs/hardware/rs485-protokol.md).
const _drawerStatusMeanings = {
  'h0': 'Çekmece kilitlendi',
  'h1': 'Kilit açık, çekmece çekilmedi',
  'h2': 'Kilit açık, istenen göze kadar açılmadı',
  'h3': 'İstenen göze gelindi, kapatılması bekleniyor',
  'h4': 'Çekmece kapatıldı',
  'h5': 'Çekmece/dolap kapalı',
  'h6': 'Çekmece/dolap açık',
  'h7': 'Döner çekmeceye sinyal gönderildi',
  'h8': 'Döner çekmece turu tamamladı',
  'h9': 'Döner çekmece turu tamamlayamadı (hata)',
  'no': 'Anlamsız komut / checksum hatası',
};

String _meaning(String? raw) {
  if (raw == null) return 'cevap yok';
  for (final e in _drawerStatusMeanings.entries) {
    if (raw.contains(e.key)) return '${e.key}: ${e.value}';
  }
  return raw.trim();
}

/// Tek bir çekmece / kübik kapak / serum kapağı üzerinde aç + durum testi.
/// Komutlar client ile aynı servis metodlarıyla gönderilir; çoklu kabinde
/// yalnız hedef kabinin açıldığı teknisyen gözlemiyle rapora işlenir.
class DrawerTestPage extends ConsumerStatefulWidget {
  const DrawerTestPage({super.key});

  @override
  ConsumerState<DrawerTestPage> createState() => _DrawerTestPageState();
}

class _DrawerTestPageState extends ConsumerState<DrawerTestPage> {
  int _address = 1;
  final _row = TextEditingController(text: '1');
  final _port = TextEditingController(text: '1');
  final _step = TextEditingController(text: '1');
  final _cubicPort = TextEditingController(text: '1');
  final _cubicIndex = TextEditingController(text: '0');
  bool _busy = false;
  String? _lastAction;
  String? _lastResult;

  @override
  void dispose() {
    for (final c in [_row, _port, _step, _cubicPort, _cubicIndex]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  ManagementCard get _manager => ManagementCard(addressIndex: _address);

  String get _target => '${addressLabel(_address)} / satır ${_row.text.trim()}';

  Future<void> _run(String title, Future<String> Function() action) async {
    setState(() => _busy = true);
    final report = ref.read(testReportProvider);
    try {
      final result = await action();
      report.add(title, StepResult.ok, detail: result);
      setState(() {
        _lastAction = title;
        _lastResult = result;
      });
    } catch (e) {
      report.add(title, StepResult.fail, detail: e.toString());
      setState(() {
        _lastAction = title;
        _lastResult = 'HATA: $e';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _validate(List<(TextEditingController, int, int, String)> fields) {
    for (final (c, min, max, name) in fields) {
      final v = _int(c);
      if (v == null || v < min || v > max) {
        showMessage(context, '$name $min–$max arasında olmalı.', error: true);
        return false;
      }
    }
    return true;
  }

  Future<void> _openDrawer() async {
    if (!_validate([(_row, 1, 26, 'Satır'), (_port, 1, 8, 'Port'), (_step, 0, 20, 'Göz/kademe')])) return;
    await _run('Çekmece aç ($_target, port ${_port.text}, göz ${_step.text})', () async {
      await ref
          .read(cabinOpsProvider)
          .openMasterDrawer(manager: _manager, row: _int(_row)!, port: _int(_port)!, drawer: _int(_step)!);
      return 'Açma komutu kabul edildi (ok)';
    });
  }

  Future<void> _drawerStatus() async {
    if (!_validate([(_row, 1, 26, 'Satır'), (_port, 1, 8, 'Port'), (_step, 0, 20, 'Göz/kademe')])) return;
    await _run('Çekmece durumu ($_target, port ${_port.text})', () async {
      final raw = await ref
          .read(cabinOpsProvider)
          .sendRawCommand(
            manager: _manager,
            targetRow: _int(_row)!,
            commandPayload: CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: _int(_port)!, drawer: _int(_step)!),
          );
      if (raw == null) throw Exception('Cevap yok (satır seçilemedi ya da kart cevap vermedi)');
      return _meaning(raw);
    });
  }

  Future<void> _openCubic() async {
    if (!_validate([(_row, 1, 26, 'Satır'), (_cubicPort, 1, 4, 'Kübik port'), (_cubicIndex, 0, 4, 'Kübik sıra')])) return;
    await _run('Kübik kapak aç ($_target, port ${_cubicPort.text}, sıra ${_cubicIndex.text})', () async {
      await ref
          .read(cabinOpsProvider)
          .openMasterCubicDrawer(manager: _manager, row: _int(_row)!, port: _int(_cubicPort)!, lidIndex: _int(_cubicIndex)!);
      return 'Kapak açma komutu kabul edildi (ok)';
    });
  }

  Future<void> _cubicStatus() async {
    if (!_validate([(_row, 1, 26, 'Satır'), (_cubicPort, 1, 4, 'Kübik port'), (_cubicIndex, 0, 4, 'Kübik sıra')])) return;
    await _run('Kübik kapak durumu ($_target, port ${_cubicPort.text}, sıra ${_cubicIndex.text})', () async {
      final status = await ref
          .read(cabinOpsProvider)
          .getMasterCubicLidStatus(manager: _manager, row: _int(_row)!, port: _int(_cubicPort)!, lidIndex: _int(_cubicIndex)!);
      return switch (status) {
        CubicLidStatus.open => 'Kapak açık (ac)',
        CubicLidStatus.closed => 'Kapak kapalı (kp)',
        CubicLidStatus.unknown => 'Bilinmiyor',
        CubicLidStatus.timeoutError => 'Zaman aşımı',
      };
    });
  }

  Future<void> _openSerum() async {
    if (!_validate([(_row, 1, 26, 'Satır')])) return;
    await _run('Serum kapağı aç ($_target)', () async {
      await ref.read(cabinOpsProvider).openMasterSerumDrawer(manager: _manager, row: _int(_row)!);
      return 'Serum açma komutu kabul edildi (ok)';
    });
  }

  Future<void> _serumStatus() async {
    if (!_validate([(_row, 1, 26, 'Satır')])) return;
    await _run('Serum kapağı durumu ($_target)', () async {
      final raw = await ref
          .read(cabinOpsProvider)
          .sendRawCommand(
            manager: _manager,
            targetRow: _int(_row)!,
            commandPayload: CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: 1, drawer: 0),
          );
      if (raw == null) throw Exception('Cevap yok');
      return _meaning(raw);
    });
  }

  /// a–p tüm adreslerde satır seçimini bırakır.
  Future<void> _releaseAll() async {
    final targets = List.generate(16, (i) => i + 1);
    await _run('Seçimleri bırak (a–p)', () async {
      final serial = ref.read(serialServiceProvider);
      final lines = <String>[];
      for (final a in targets) {
        String? r;
        try {
          r = await serial.sendAndReceive(
            CommandBuilder.buildManagementCommand(addressIndex: a, row: 0),
            timeout: const Duration(milliseconds: 300),
          );
        } catch (_) {}
        lines.add('${addressLabel(a)}: ${r?.trim() ?? 'cevap yok'}');
      }
      return lines.join('\n');
    });
  }

  void _observe(bool onlyTarget) {
    ref
        .read(testReportProvider)
        .add(
          onlyTarget ? 'Gözlem: yalnız hedef kabin/çekmece açıldı' : 'Gözlem: BAŞKA kabin/çekmece de açıldı',
          onlyTarget ? StepResult.ok : StepResult.fail,
          detail: _lastAction,
        );
    showMessage(context, 'Gözlem rapora eklendi.');
  }

  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(sessionProvider.select((s) => s.port != null));
    final enabled = connected && !_busy;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          title: 'Hedef',
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Yönetim kartı:'),
              AddressPicker(value: _address, onChanged: (v) => setState(() => _address = v)),
              NumberField(label: 'Satır (1–26)', controller: _row),
              if (!connected) const Text('Önce COM porta bağlanın.', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        SectionCard(
          title: 'Standart çekmece',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NumberField(label: 'Port (1–8)', controller: _port),
              NumberField(label: 'Göz (0–16, 20)', controller: _step),
              BusyButton(label: 'Aç', icon: Icons.lock_open, busy: _busy, onPressed: enabled ? _openDrawer : null),
              OutlinedButton(onPressed: enabled ? _drawerStatus : null, child: const Text('Durum oku')),
              const Text('Kübik çekmecenin ana kilidi de buradan açılır.', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        SectionCard(
          title: 'Kübik kapak',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NumberField(label: 'Port (1–4)', controller: _cubicPort),
              NumberField(label: 'Sıra (0–4)', controller: _cubicIndex),
              BusyButton(label: 'Kapağı aç', icon: Icons.lock_open, busy: _busy, onPressed: enabled ? _openCubic : null),
              OutlinedButton(onPressed: enabled ? _cubicStatus : null, child: const Text('Durum oku')),
              const Text('Çekmece açık değilse kart "ht" döner.', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        SectionCard(
          title: 'Serum kapağı (master kabin)',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              BusyButton(label: 'Serum kapağını aç', icon: Icons.lock_open, busy: _busy, onPressed: enabled ? _openSerum : null),
              OutlinedButton(onPressed: enabled ? _serumStatus : null, child: const Text('Durum oku')),
            ],
          ),
        ),
        SectionCard(
          title: 'Çoklu kabin kontrolü',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aynı hatta birden fazla kabin varsa, açma komutundan sonra yalnız hedef kabinin açıldığını kontrol edip '
                'gözleminizi işaretleyin. Gerekirse önce tüm kabinlerde satır seçimini bırakın.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: enabled ? _releaseAll : null,
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Tüm kabinlerde seçimi bırak'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _lastAction == null ? null : () => _observe(true),
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    label: const Text('Yalnız hedef açıldı'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _lastAction == null ? null : () => _observe(false),
                    icon: const Icon(Icons.error, color: Colors.red),
                    label: const Text('Başka kabin de açıldı'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_lastAction != null)
          SectionCard(
            title: 'Son işlem',
            child: Text('$_lastAction\n$_lastResult', style: const TextStyle(fontFamily: 'Consolas')),
          ),
      ],
    );
  }
}
