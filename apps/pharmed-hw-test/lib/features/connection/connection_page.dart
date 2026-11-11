import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/common.dart';

/// İstasyon seçimi (kabinler ve yönetim kartı adresleri servisten) + COM port bağlantısı.
class ConnectionPage extends ConsumerStatefulWidget {
  const ConnectionPage({super.key});

  @override
  ConsumerState<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends ConsumerState<ConnectionPage> {
  List<Station> _stations = [];
  bool _loadingStations = false;
  bool _loadingCabins = false;
  String? _stationError;

  List<String> _ports = [];
  String? _selectedPort;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _loadStations();
    _refreshPorts();
  }

  Future<void> _loadStations() async {
    setState(() {
      _loadingStations = true;
      _stationError = null;
    });
    final result = await ref.read(stationRepositoryProvider).getStations(take: 1000);
    if (!mounted) return;
    result.when(
      ok: (res) => setState(() {
        _stations = [...(res.data ?? const <Station>[])]..sort((a, b) => a.title.compareTo(b.title));
        _loadingStations = false;
      }),
      error: (e) => setState(() {
        _stationError = e.message;
        _loadingStations = false;
      }),
    );
  }

  Future<void> _selectStation(Station station) async {
    final id = station.id;
    if (id == null) return;
    setState(() => _loadingCabins = true);
    final result = await ref.read(cabinRepositoryProvider).getCabinsByStation(id);
    if (!mounted) return;
    setState(() => _loadingCabins = false);
    result.when(
      ok: (cabins) {
        ref.read(sessionProvider.notifier).setStation(station, cabins);
        ref
            .read(testReportProvider)
            .add(
              'İstasyon seçildi: ${station.title}',
              StepResult.info,
              detail: cabins
                  .map((c) => '${c.name ?? '-'}  adres ${c.no?.toUpperCase() ?? '?'}  ${c.type?.name ?? ''}  ${c.comPort?.label ?? ''}')
                  .join('\n'),
            );
        // Kayıtlı COM port (master kabin) varsa öner.
        final master = cabins.where((c) => c.type == CabinType.master && c.comPort != null).firstOrNull;
        if (_selectedPort == null && master != null && _ports.contains(master.comPort!.label)) {
          setState(() => _selectedPort = master.comPort!.label);
        }
      },
      error: (e) => showMessage(context, 'Kabinler alınamadı: ${e.message}', error: true),
    );
  }

  void _refreshPorts() {
    final ports = ref.read(serialServiceProvider).getAvailablePorts();
    setState(() {
      _ports = ports;
      if (_selectedPort != null && !ports.contains(_selectedPort)) _selectedPort = null;
      _selectedPort ??= ports.isNotEmpty ? ports.first : null;
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
    final session = ref.watch(sessionProvider);
    final connected = session.port != null;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          title: '1. İstasyon',
          trailing: IconButton(onPressed: _loadStations, icon: const Icon(Icons.refresh), tooltip: 'Yenile'),
          child: _loadingStations
              ? const LinearProgressIndicator()
              : _stationError != null
              ? Text('İstasyonlar alınamadı: $_stationError', style: const TextStyle(color: Colors.red))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownMenu<Station>(
                      width: 420,
                      label: const Text('Test edilecek istasyon'),
                      initialSelection: session.station,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      dropdownMenuEntries: [
                        for (final s in _stations) DropdownMenuEntry(value: s, label: s.title),
                      ],
                      onSelected: (s) {
                        if (s != null) _selectStation(s);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_loadingCabins) const LinearProgressIndicator(),
                    if (session.station != null && !_loadingCabins) _CabinTable(cabins: session.cabins),
                  ],
                ),
        ),
        SectionCard(
          title: '2. COM port',
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
                connected ? '${session.port} bağlı' : 'Bağlı değil',
                style: TextStyle(color: connected ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const Text(
          'Bağlandıktan sonra "Hat taraması" ile hangi kabinlerin cevap verdiğini kontrol edin.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _CabinTable extends StatelessWidget {
  const _CabinTable({required this.cabins});

  final List<Cabin> cabins;

  @override
  Widget build(BuildContext context) {
    if (cabins.isEmpty) return const Text('Bu istasyonda kayıtlı kabin yok.');
    return DataTable(
      headingRowHeight: 36,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 40,
      columns: const [
        DataColumn(label: Text('Kabin')),
        DataColumn(label: Text('Yönetim kartı adresi')),
        DataColumn(label: Text('Tip')),
        DataColumn(label: Text('COM port')),
      ],
      rows: [
        for (final c in cabins)
          DataRow(
            cells: [
              DataCell(Text(c.name ?? '-')),
              DataCell(Text(c.no?.toUpperCase() ?? '?')),
              DataCell(Text(c.type?.name ?? '-')),
              DataCell(Text(c.comPort?.label ?? '-')),
            ],
          ),
      ],
    );
  }
}
