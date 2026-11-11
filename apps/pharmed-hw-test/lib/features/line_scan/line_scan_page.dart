import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/common.dart';

class _AddressResult {
  _AddressResult({required this.address, required this.expectedCabin, required this.response});

  final int address;
  final String? expectedCabin;
  final String? response;
  ({double temperature, double humidity})? tempHum;
  double? battery;

  bool get responded => response != null && response!.contains('ok');

  StepResult get result {
    if (expectedCabin != null) return responded ? StepResult.ok : StepResult.fail;
    return responded ? StepResult.fail : StepResult.info;
  }

  String get verdict {
    if (expectedCabin != null) return responded ? 'Kabin cevap veriyor' : 'Kabin cevap vermiyor';
    return responded ? 'İstasyonda tanımlı olmayan kart!' : '-';
  }
}

/// a–p adreslerinin hepsine `:Y?00c;` gönderir: hangi yönetim kartları hatta,
/// istasyondaki kabin tanımlarıyla uyuşuyor mu, sensör değerleri ne.
/// Satır 00 aynı zamanda seçimi bıraktığı için tarama hatta açık seçim bırakmaz.
class LineScanPage extends ConsumerStatefulWidget {
  const LineScanPage({super.key});

  @override
  ConsumerState<LineScanPage> createState() => _LineScanPageState();
}

class _LineScanPageState extends ConsumerState<LineScanPage> {
  List<_AddressResult> _results = [];
  bool _busy = false;
  bool _readSensors = true;

  Future<void> _scan() async {
    final serial = ref.read(serialServiceProvider);
    final ops = ref.read(cabinOpsProvider);
    final cabins = ref.read(sessionProvider).cabins;
    setState(() {
      _busy = true;
      _results = [];
    });

    final results = <_AddressResult>[];
    for (var address = 1; address <= 16; address++) {
      String? response;
      for (var attempt = 0; attempt < 2 && (response == null || !response.contains('ok')); attempt++) {
        try {
          response = await serial.sendAndReceive(
            CommandBuilder.buildManagementCommand(addressIndex: address, row: 0),
            timeout: const Duration(milliseconds: 300),
          );
        } catch (_) {}
      }
      final r = _AddressResult(address: address, expectedCabin: cabinNameForAddress(cabins, address), response: response);
      if (r.responded && _readSensors) {
        final manager = ManagementCard(addressIndex: address);
        r.tempHum = await ops.readTempHumidity(manager: manager);
        r.battery = await ops.readBatteryVoltage(manager: manager);
        // Sensör satırı (49/50) seçili kalmasın.
        try {
          await serial.sendAndReceive(
            CommandBuilder.buildManagementCommand(addressIndex: address, row: 0),
            timeout: const Duration(milliseconds: 300),
          );
        } catch (_) {}
      }
      results.add(r);
      if (mounted) setState(() => _results = [...results]);
    }

    final found = results.where((r) => r.responded).map((r) => addressLabel(r.address)).join(', ');
    final missing = results.where((r) => r.expectedCabin != null && !r.responded).map((r) => '${addressLabel(r.address)} (${r.expectedCabin})');
    final unexpected = results.where((r) => r.expectedCabin == null && r.responded).map((r) => addressLabel(r.address));
    final ok = missing.isEmpty && unexpected.isEmpty;
    ref
        .read(testReportProvider)
        .add(
          'Hat taraması',
          ok ? StepResult.ok : StepResult.fail,
          detail: [
            'Cevap veren adresler: ${found.isEmpty ? 'yok' : found}',
            if (missing.isNotEmpty) 'Cevap vermeyen kabinler: ${missing.join(', ')}',
            if (unexpected.isNotEmpty) 'Tanımsız kart: ${unexpected.join(', ')}',
            for (final r in results.where((r) => r.responded))
              '${addressLabel(r.address)}: ${_sensorText(r)}',
          ].join('\n'),
        );
    if (mounted) setState(() => _busy = false);
  }

  String _sensorText(_AddressResult r) {
    final th = r.tempHum;
    final parts = [
      if (th != null) '${th.temperature.toStringAsFixed(1)} °C / %${th.humidity.toStringAsFixed(1)}',
      if (r.battery != null) 'akü ${r.battery!.toStringAsFixed(2)} V',
    ];
    return parts.isEmpty ? '-' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(sessionProvider.select((s) => s.port != null));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          title: 'Hat taraması (yönetim kartları a–p)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Her adrese satır 00 komutu gönderilir. Cevap veren adresler istasyondaki kabin tanımlarıyla '
                'karşılaştırılır. Satır 00 seçimi de bıraktığı için tarama hatta açık seçim bırakmaz.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  BusyButton(label: 'Taramayı başlat', busy: _busy, onPressed: connected ? _scan : null),
                  const SizedBox(width: 16),
                  Checkbox(value: _readSensors, onChanged: (v) => setState(() => _readSensors = v ?? true)),
                  const Text('Isı/nem ve akü oku'),
                  if (!connected) ...[
                    const SizedBox(width: 16),
                    const Text('Önce COM porta bağlanın.', style: TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (_results.isNotEmpty)
          SectionCard(
            title: 'Sonuç',
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              columns: const [
                DataColumn(label: Text('Adres')),
                DataColumn(label: Text('İstasyondaki kabin')),
                DataColumn(label: Text('Ham cevap')),
                DataColumn(label: Text('Sensörler')),
                DataColumn(label: Text('Durum')),
              ],
              rows: [
                for (final r in _results)
                  DataRow(
                    cells: [
                      DataCell(Text(addressLabel(r.address), style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text(r.expectedCabin ?? '-')),
                      DataCell(Text(r.response?.trim() ?? '(cevap yok)', style: const TextStyle(fontFamily: 'Consolas'))),
                      DataCell(Text(r.responded ? _sensorText(r) : '-')),
                      DataCell(ResultBadge(result: r.result, label: r.verdict)),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
