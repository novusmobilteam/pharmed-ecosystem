import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/address_picker.dart';
import '../../widgets/common.dart';

class _CardRow {
  _CardRow({required this.card, required this.matches, required this.types});

  final ControlCard card;

  /// Kartın tip numarasıyla eşleşen TÜM tanımlar (client ilkini seçer).
  final List<DrawerConfig> matches;
  final Map<int, DrawerType> types;

  /// [tt (00-04)][port (1-4)] → ham cevap. null: henüz yoklanmadı.
  List<List<String?>>? cubicProbe;
  bool probing = false;

  DrawerType? typeOf(DrawerConfig c) => types[c.drawerTypeId];

  int get cubicActiveCount =>
      cubicProbe?.expand((r) => r).where((r) => r != null && r.contains('ok')).length ?? 0;
}

/// Seçilen yönetim kartındaki kontrol kartlarını client'taki taramayla aynı kodla
/// (`discoverControlCards`) bulur; ham tip cevabını, tip numarasıyla eşleşen
/// tanımları ve kübikte hangi slave/gözlerin cevap verdiğini gösterir.
class CardScanPage extends ConsumerStatefulWidget {
  const CardScanPage({super.key});

  @override
  ConsumerState<CardScanPage> createState() => _CardScanPageState();
}

class _CardScanPageState extends ConsumerState<CardScanPage> {
  int _address = 1;
  bool _busy = false;
  List<_CardRow> _rows = [];
  String? _error;

  Future<void> _scan() async {
    setState(() {
      _busy = true;
      _rows = [];
      _error = null;
    });
    final repo = ref.read(cabinRepositoryProvider);
    final configsRes = await repo.getDrawerConfigs(forceRefresh: true);
    final typesRes = await repo.getDrawerTypes(forceRefresh: true);
    final configs = configsRes.data;
    final types = typesRes.data;
    if (configs == null || types == null) {
      setState(() {
        _busy = false;
        _error = 'Çekmece tanımları servisten alınamadı.';
      });
      ref.read(testReportProvider).add('Kart taraması (${addressLabel(_address)})', StepResult.fail, detail: _error);
      return;
    }
    final typeMap = {for (final t in types) if (t.id != null) t.id!: t};

    final manager = ManagementCard(addressIndex: _address);
    final cards = await ref.read(cabinOpsProvider).discoverControlCards(manager);
    final rows = [
      for (final card in cards)
        _CardRow(
          card: card,
          matches: configs.where((c) => c.deviceTypeNo == card.databaseTypeId).toList(),
          types: typeMap,
        ),
    ];

    final problems = rows.where((r) => r.matches.length != 1).length;
    ref
        .read(testReportProvider)
        .add(
          'Kart taraması (${addressLabel(_address)}): ${rows.length} kart',
          cards.isEmpty || problems > 0 ? StepResult.fail : StepResult.ok,
          detail: rows.map(_describe).join('\n'),
        );
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _busy = false;
      if (cards.isEmpty) _error = 'Bu adreste kontrol kartı bulunamadı.';
    });
  }

  String _describe(_CardRow r) {
    final defs = r.matches.isEmpty
        ? 'EŞLEŞEN TANIM YOK'
        : r.matches
              .map((c) {
                final t = r.typeOf(c);
                return 'config ${c.id} → ${t?.name ?? 'tip ${c.drawerTypeId}?'} (${t?.compartmentCount ?? '?'} göz${t?.isKubik == true ? ', kübik' : ''})';
              })
              .join(' | ');
    final warn = r.matches.length > 1 ? '  [UYARI: ${r.matches.length} tanım aynı tip no — client ilkini seçer]' : '';
    final cubic = r.cubicProbe == null ? '' : '  kübik: ${r.cubicActiveCount} göz cevap verdi';
    return 'Satır ${r.card.rowAddress.toString().padLeft(2, '0')}  ham ${r.card.rawTypeResponse.trim()}  tip ${r.card.databaseTypeId}  $defs$warn$cubic';
  }

  Future<void> _probeCubic(_CardRow row) async {
    final ops = ref.read(cabinOpsProvider);
    final manager = ManagementCard(addressIndex: _address);
    setState(() => row.probing = true);
    final grid = List.generate(5, (_) => List<String?>.filled(4, null));
    for (var tt = 0; tt <= 4; tt++) {
      for (var port = 1; port <= 4; port++) {
        String? response;
        try {
          response = await ops.sendRawCommand(
            manager: manager,
            targetRow: row.card.rowAddress,
            commandPayload: CommandBuilder.buildCubicCommand(action: DeviceAction.ping, port: port, row: tt),
          );
        } catch (e) {
          response = 'hata';
        }
        grid[tt][port - 1] = response?.trim() ?? '-';
        if (mounted) setState(() => row.cubicProbe = grid.map((r) => [...r]).toList());
      }
    }
    await _release();
    row.cubicProbe = grid;
    ref
        .read(testReportProvider)
        .add(
          'Kübik yoklama (${addressLabel(_address)} / satır ${row.card.rowAddress})',
          StepResult.info,
          detail: [
            '${row.cubicActiveCount} göz "ok" döndü',
            for (var tt = 0; tt <= 4; tt++) 'sıra ${tt.toString().padLeft(2, '0')}: ${grid[tt].join('  ')}',
          ].join('\n'),
        );
    if (mounted) setState(() => row.probing = false);
  }

  Future<void> _release() async {
    try {
      await ref
          .read(serialServiceProvider)
          .sendAndReceive(
            CommandBuilder.buildManagementCommand(addressIndex: _address, row: 0),
            timeout: const Duration(milliseconds: 300),
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(sessionProvider.select((s) => s.port != null));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          title: 'Kart taraması',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seçilen yönetim kartında satır 01–26 taranır (client taramasıyla aynı kod). Her kart için ham tip cevabı '
                've bu tip numarasıyla eşleşen servis tanımları gösterilir. Birden fazla tanım eşleşirse client ilkini seçer.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Yönetim kartı: '),
                  AddressPicker(value: _address, onChanged: (v) => setState(() => _address = v)),
                  const SizedBox(width: 16),
                  BusyButton(label: 'Kartları tara', busy: _busy, onPressed: connected ? _scan : null),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
        for (final row in _rows) _CardTile(row: row, describe: _describe, onProbe: () => _probeCubic(row)),
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.row, required this.describe, required this.onProbe});

  final _CardRow row;
  final String Function(_CardRow) describe;
  final VoidCallback onProbe;

  @override
  Widget build(BuildContext context) {
    final ok = row.matches.length == 1;
    final type = ok ? row.typeOf(row.matches.first) : null;
    final isKubik = row.matches.any((c) => row.typeOf(c)?.isKubik ?? false);
    final mono = const TextStyle(fontFamily: 'Consolas');
    return SectionCard(
      title: 'Satır ${row.card.rowAddress.toString().padLeft(2, '0')} — ${type?.name ?? (row.card.isSerum ? 'Serum kartı' : 'Tip ${row.card.databaseTypeId}')}',
      trailing: ResultBadge(
        result: ok ? StepResult.ok : StepResult.fail,
        label: row.matches.isEmpty ? 'Tanım yok' : (ok ? '${type?.compartmentCount ?? '?'} göz' : '${row.matches.length} tanım eşleşti'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ham tip cevabı: ${row.card.rawTypeResponse.trim()}   →   tip no ${row.card.databaseTypeId}', style: mono),
          const SizedBox(height: 6),
          for (final c in row.matches)
            Text(
              '• config ${c.id}: ${row.typeOf(c)?.name ?? 'tip ${c.drawerTypeId} bulunamadı'} — '
              '${row.typeOf(c)?.compartmentCount ?? '?'} göz${(row.typeOf(c)?.isKubik ?? false) ? ', kübik' : ''}',
            ),
          if (row.matches.length > 1)
            const Text(
              'Aynı tip numarasına birden fazla tanım bağlı: client ilk tanımı seçer, çekmece yanlış tipte görünebilir.',
              style: TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: row.probing ? null : onProbe,
                icon: const Icon(Icons.grid_view),
                label: Text(isKubik ? 'Kübik gözleri yokla' : 'Kübik yokla (Z M)'),
              ),
              if (row.probing) ...[
                const SizedBox(width: 12),
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
              if (row.cubicProbe != null && !row.probing) ...[
                const SizedBox(width: 12),
                Text('${row.cubicActiveCount} göz cevap verdi', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          if (row.cubicProbe != null) ...[
            const SizedBox(height: 8),
            Table(
              defaultColumnWidth: const FixedColumnWidth(90),
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  children: [
                    const Padding(padding: EdgeInsets.all(4), child: Text('sıra \\ port')),
                    for (var p = 1; p <= 4; p++) Padding(padding: const EdgeInsets.all(4), child: Text('port $p')),
                  ],
                ),
                for (var tt = 0; tt < row.cubicProbe!.length; tt++)
                  TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(4), child: Text(tt.toString().padLeft(2, '0'))),
                      for (final cell in row.cubicProbe![tt])
                        Container(
                          padding: const EdgeInsets.all(4),
                          color: cell == null
                              ? null
                              : (cell.contains('ok') ? Colors.green.shade50 : Colors.red.shade50),
                          child: Text(cell ?? '…', style: mono),
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
