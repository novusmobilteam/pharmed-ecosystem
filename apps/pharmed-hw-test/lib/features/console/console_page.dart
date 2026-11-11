import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/common.dart';
import '../home/traffic_panel.dart';

enum _Kind { management, drawer, cubic, raw }

/// Ham komut konsolu: komut alanlardan checksum'ıyla üretilir ya da elle yazılır.
class ConsolePage extends ConsumerStatefulWidget {
  const ConsolePage({super.key});

  @override
  ConsumerState<ConsolePage> createState() => _ConsolePageState();
}

class _ConsolePageState extends ConsumerState<ConsolePage> {
  _Kind _kind = _Kind.management;
  int _address = 1;
  DeviceAction _action = DeviceAction.status;
  final _row = TextEditingController(text: '0');
  final _port = TextEditingController(text: '1');
  final _value = TextEditingController(text: '1');
  final _raw = TextEditingController();
  final _timeout = TextEditingController(text: '500');
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_row, _port, _value, _raw, _timeout]) {
      c.dispose();
    }
    super.dispose();
  }

  int _int(TextEditingController c) => int.tryParse(c.text.trim()) ?? -1;

  /// Önizleme; geçersiz alanda hata metni döner.
  ({String? command, String? error}) _build() {
    try {
      final command = switch (_kind) {
        _Kind.management => CommandBuilder.buildManagementCommand(addressIndex: _address, row: _int(_row)),
        _Kind.drawer => CommandBuilder.buildDrawerCommand(action: _action, port: _int(_port), drawer: _int(_value)),
        _Kind.cubic => CommandBuilder.buildCubicCommand(action: _action, port: _int(_port), row: _int(_value)),
        _Kind.raw => _raw.text.trim(),
      };
      if (command.isEmpty) return (command: null, error: 'Komut yazın.');
      return (command: command, error: null);
    } on ArgumentError catch (e) {
      return (command: null, error: e.message.toString());
    }
  }

  Future<void> _send() async {
    final built = _build();
    final command = built.command;
    if (command == null) return;
    setState(() => _busy = true);
    try {
      final response = await ref
          .read(serialServiceProvider)
          .sendAndReceive(command, timeout: Duration(milliseconds: _int(_timeout).clamp(50, 10000)));
      ref.read(testReportProvider).add('Konsol: $command', StepResult.info, detail: 'Cevap: ${response?.trim() ?? '(yok)'}');
    } catch (e) {
      ref.read(testReportProvider).add('Konsol: $command', StepResult.fail, detail: e.toString());
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(sessionProvider.select((s) => s.port != null));
    final built = _build();
    final actions = _kind == _Kind.cubic
        ? const [DeviceAction.open, DeviceAction.status, DeviceAction.ping, DeviceAction.type]
        : DeviceAction.values;
    if (!actions.contains(_action)) _action = DeviceAction.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SectionCard(
            title: 'Komut',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<_Kind>(
                  segments: const [
                    ButtonSegment(value: _Kind.management, label: Text('Yönetim (Y)')),
                    ButtonSegment(value: _Kind.drawer, label: Text('Çekmece (T)')),
                    ButtonSegment(value: _Kind.cubic, label: Text('Kübik (Z)')),
                    ButtonSegment(value: _Kind.raw, label: Text('Elle yaz')),
                  ],
                  selected: {_kind},
                  onSelectionChanged: (s) => setState(() => _kind = s.first),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_kind == _Kind.management) ...[
                      DropdownButton<int>(
                        value: _address,
                        items: [for (var i = 1; i <= 16; i++) DropdownMenuItem(value: i, child: Text('Adres ${addressLabel(i)}'))],
                        onChanged: (v) => setState(() => _address = v ?? 1),
                      ),
                      _field('Satır (00 = bırak, 49 akü, 50 ısı/nem)', _row, 280),
                    ],
                    if (_kind == _Kind.drawer || _kind == _Kind.cubic) ...[
                      DropdownButton<DeviceAction>(
                        value: _action,
                        items: [
                          for (final a in actions) DropdownMenuItem(value: a, child: Text('${a.code} — ${_actionName(a)}')),
                        ],
                        onChanged: (v) => setState(() => _action = v ?? DeviceAction.status),
                      ),
                      _field(_kind == _Kind.drawer ? 'Port (1–8)' : 'Port (1–4)', _port, 120),
                      _field(_kind == _Kind.drawer ? 'Göz (00–16, 20)' : 'Sıra (00–04)', _value, 140),
                    ],
                    if (_kind == _Kind.raw) _field('Komut (ör. :Ya000;)', _raw, 280),
                    _field('Zaman aşımı (ms)', _timeout, 140),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      built.command ?? built.error ?? '',
                      style: TextStyle(
                        fontFamily: 'Consolas',
                        fontSize: 18,
                        color: built.command == null ? Colors.red : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    BusyButton(
                      label: 'Gönder',
                      icon: Icons.send,
                      busy: _busy,
                      onPressed: connected && built.command != null ? _send : null,
                    ),
                    if (!connected) ...[
                      const SizedBox(width: 12),
                      const Text('Önce COM porta bağlanın.', style: TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
                if (_kind == _Kind.drawer || _kind == _Kind.cubic)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'T/Z komutları adres taşımaz: önce Y ile hedef kartta satırı seçin, sonra komutu gönderin.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Expanded(child: TrafficPanel()),
      ],
    );
  }

  Widget _field(String label, TextEditingController c, double width) => SizedBox(
    width: width,
    child: TextField(
      controller: c,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
    ),
  );

  String _actionName(DeviceAction a) => switch (a) {
    DeviceAction.open => 'Aç',
    DeviceAction.close => 'Kapat',
    DeviceAction.status => 'Durum',
    DeviceAction.ping => 'Orada mısın?',
    DeviceAction.type => 'Tip',
    DeviceAction.reset => 'Sıfırla',
  };
}
