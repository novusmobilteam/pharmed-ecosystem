import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/common.dart';

/// COM port bağlantısı. Test uygulaması istasyondan bağımsızdır.
class ConnectionPage extends ConsumerStatefulWidget {
  const ConnectionPage({super.key});

  @override
  ConsumerState<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends ConsumerState<ConnectionPage> {
  List<String> _ports = [];
  String? _selectedPort;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _refreshPorts();
  }

  void _refreshPorts() {
    final ports = ref.read(serialServiceProvider).getAvailablePorts();
    setState(() {
      _ports = ports;
      if (_selectedPort != null && !ports.contains(_selectedPort)) _selectedPort = null;
      // Bağlı port varsa (ör. kabin tipi değişince sayfa yeniden kuruldu) onu göster.
      _selectedPort ??= ref.read(sessionProvider).port ?? (ports.isNotEmpty ? ports.first : null);
    });
  }

  Future<void> _connect() async {
    final port = _selectedPort;
    if (port == null) return;
    setState(() => _connecting = true);
    final serial = ref.read(serialServiceProvider);
    try {
      await serial.connectToPort(port);
      ref.read(sessionProvider.notifier).setPort(port);
      ref.read(testReportProvider).add('COM port bağlandı: $port', StepResult.ok);
    } catch (e) {
      ref.read(testReportProvider).add('COM port bağlanamadı: $port', StepResult.fail, detail: e.toString());
      if (mounted) showMessage(context, 'Bağlanamadı: $e', error: true);
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _disconnect() async {
    await ref.read(serialServiceProvider).disconnect();
    ref.read(sessionProvider.notifier).setPort(null);
    ref.read(testReportProvider).add('COM port bağlantısı kesildi', StepResult.info);
  }

  @override
  Widget build(BuildContext context) {
    final port = ref.watch(sessionProvider.select((s) => s.port));
    final connected = port != null;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          title: 'COM port',
          trailing: IconButton(onPressed: _refreshPorts, icon: const Icon(Icons.refresh), tooltip: 'Portları yenile'),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<String>(
                value: _selectedPort,
                hint: const Text('Port yok'),
                items: [for (final p in _ports) DropdownMenuItem(value: p, child: Text(p))],
                onChanged: connected ? null : (p) => setState(() => _selectedPort = p),
              ),
              if (!connected)
                BusyButton(label: 'Bağlan', icon: Icons.link, busy: _connecting, onPressed: _selectedPort == null ? null : _connect)
              else
                OutlinedButton.icon(onPressed: _disconnect, icon: const Icon(Icons.link_off), label: const Text('Bağlantıyı kes')),
              Text(
                connected ? '$port bağlı' : 'Bağlı değil',
                style: TextStyle(
                  color: connected ? TestStatus.passed.color : TestStatus.failed.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          'Bağlandıktan sonra "Hat taraması" ile hattaki yönetim kartlarını (kabinleri) bulun. '
          'RFID okuyucu ağ üzerinden bağlanır; COM port gerekmez.',
          style: hintStyle(),
        ),
      ],
    );
  }
}
