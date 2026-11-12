import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/address_picker.dart';
import '../../widgets/common.dart';
import 'tray_lock_section.dart';

// Serum kabini (tip 250) kapak keşfi — issue #183.
//
// Client bugün serum kartını tek çekmece sayar ve hep `port 1 · göz 00`
// adresini açar. Bu sayfa kartın kapakları nasıl adreslediğini sahada
// öğrenmek için:
//   1. Serum kartını bul      : satır taraması, `.250` dönen kartlar + servis tanımı
//   2. Kapak keşfi (güvenli)  : M / V / S komutları — AÇMA KOMUTU GÖNDERMEZ
//   3. Aç + eşleştir          : seçilen adres açılır, teknisyen hangi kapağın
//                               açıldığını işaretler → adres → kapak tablosu
//   4. Kapak testi (#197)     : client'ın kullandığı `openMasterSerumDrawer(port)`
//                               ile kapak 1–N sırayla açılır, teknisyen onaylar

/// Kapak adresi: `T` komutundaki port (1–8) ve göz/kademe (00–16) alanı.
@immutable
class _LidAddress {
  const _LidAddress(this.port, this.drawer);

  final int port;
  final int drawer;

  String get label => 'port $port · göz ${drawer.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) => other is _LidAddress && other.port == port && other.drawer == drawer;

  @override
  int get hashCode => Object.hash(port, drawer);
}

/// Kapakların hangi alanla ayrıldığına dair iki aday şema.
enum _Scheme {
  ports('Port 1–8, göz 00', 'Her kapak ayrı port (mobil kabindeki gibi)'),
  drawers('Port 1, göz 01–08', 'Tek port, kapaklar göz numarasıyla');

  const _Scheme(this.title, this.hint);

  final String title;
  final String hint;

  List<_LidAddress> get addresses => switch (this) {
    _Scheme.ports => [for (var p = 1; p <= 8; p++) _LidAddress(p, 0)],
    _Scheme.drawers => [for (var d = 1; d <= 8; d++) _LidAddress(1, d)],
  };
}

/// Keşifte gönderilen komutlar (hiçbiri kapağı açmaz).
const _probeActions = [DeviceAction.ping, DeviceAction.type, DeviceAction.status];

/// `.xx,` çerçevesinin içini döner; çerçeve yoksa ham metni kırpar.
String? _payload(String? raw) {
  if (raw == null) return null;
  final m = RegExp(r'\.([^,]*),').firstMatch(raw);
  return (m?.group(1) ?? raw).trim();
}

/// Ham cevabın protokoldeki anlamı (docs/hardware/rs485-protokol.md).
String _meaning(String? raw) {
  final v = _payload(raw);
  if (v == null) return 'cevap yok';
  return switch (v) {
    'ok' => 'anlaşıldı',
    'no' => 'anlamsız komut / solenoid yok',
    'nc' => 'checksum hatası',
    'h0' => 'kilitlendi',
    'h1' => 'kilit açık, çekilmedi',
    'h2' => 'çekildi, eksik açıldı',
    'h3' => 'açık, kapatılması bekleniyor',
    'h4' => 'kapatıldı',
    'h5' => 'kapalı',
    'h6' => 'açık',
    'h7' || 'h8' || 'h9' => 'döner motor durumu ($v)',
    _ when RegExp(r'^v?\d+$').hasMatch(v) => 'tip ${v.replaceFirst('v', '')}',
    _ => v,
  };
}

/// Cevap var ve hata değil → bu adreste bir şey dinliyor.
bool _isAlive(String? raw) {
  final v = _payload(raw);
  return v != null && v.isNotEmpty && v != 'no' && v != 'nc';
}

bool _isOpen(String? raw) {
  final v = _payload(raw);
  return v == 'h1' || v == 'h2' || v == 'h3' || v == 'h6';
}

class SerumCabinPage extends ConsumerStatefulWidget {
  const SerumCabinPage({super.key});

  @override
  ConsumerState<SerumCabinPage> createState() => _SerumCabinPageState();
}

class _SerumCabinPageState extends ConsumerState<SerumCabinPage> {
  int _address = 1;
  final _rowCtrl = TextEditingController();

  // 1. Kart bulma
  bool _finding = false;
  List<ControlCard>? _serumCards;
  String? _definitionInfo;

  // 2. Keşif
  _Scheme _scheme = _Scheme.ports;
  bool _probing = false;
  final Map<_LidAddress, Map<DeviceAction, String?>> _probe = {};

  // 3. Aç + eşleştir
  _LidAddress _target = const _LidAddress(1, 0);
  bool _opening = false;
  String? _openResult;
  String? _targetStatus;
  Timer? _watchTimer;
  bool _polling = false;
  _LidAddress? _awaitingObservation;
  final Map<_LidAddress, String> _mapping = {};

  // 4. Kapak testi — client komutuyla
  int _lidCount = DeviceConstants.maxSerumLids;
  int? _lidBusy;
  final Map<int, String> _lidResult = {};
  final Map<int, bool> _lidConfirmed = {};

  ManagementCard get _manager => ManagementCard(addressIndex: _address);
  int? get _row => int.tryParse(_rowCtrl.text.trim());
  String get _where => '${addressLabel(_address)}, satır ${_row ?? '-'}';

  @override
  void dispose() {
    _watchTimer?.cancel();
    _rowCtrl.dispose();
    super.dispose();
  }

  // ── Seri hat yardımcıları ─────────────────────────────────────

  ISerialCommunicationService get _serial => ref.read(serialServiceProvider);

  Future<bool> _selectRow(int row) async {
    try {
      final r = await _serial.sendAndReceive(
        CommandBuilder.buildManagementCommand(addressIndex: _address, row: row),
        timeout: const Duration(milliseconds: 800),
      );
      return r != null && r.contains('ok');
    } catch (_) {
      return false;
    }
  }

  Future<String?> _send(DeviceAction action, _LidAddress a, {Duration? timeout}) async {
    try {
      return await _serial.sendAndReceive(
        CommandBuilder.buildDrawerCommand(action: action, port: a.port, drawer: a.drawer),
        timeout: timeout ?? const Duration(milliseconds: 400),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _release() => _selectRow(0);

  // ── 1. Serum kartını bul ──────────────────────────────────────

  Future<void> _findCards() async {
    setState(() {
      _finding = true;
      _serumCards = null;
      _definitionInfo = null;
    });

    final repo = ref.read(cabinRepositoryProvider);
    final configs = (await repo.getDrawerConfigs(forceRefresh: true)).data;
    final types = (await repo.getDrawerTypes(forceRefresh: true)).data;
    final serumDefs = configs?.where((c) => c.isSerum).toList() ?? const <DrawerConfig>[];
    final defInfo = configs == null
        ? 'Servis tanımları alınamadı.'
        : serumDefs.isEmpty
        ? 'Serviste tip 250 için tanım YOK — client bu kartı eşleştiremez.'
        : serumDefs
              .map((c) {
                final t = types?.where((t) => t.id == c.drawerTypeId).firstOrNull;
                return 'Tanım #${c.id}: ${t?.name ?? 'tip ${c.drawerTypeId}'} · ${t?.compartmentCount ?? '?'} göz';
              })
              .join('\n');

    final cards = await ref.read(cabinOpsProvider).discoverControlCards(_manager);
    final serum = cards.where((c) => c.isSerum).toList();
    if (serum.isNotEmpty && _row == null) _rowCtrl.text = serum.first.rowAddress.toString();

    ref
        .read(testReportProvider)
        .add(
          'Serum kartı arama (${addressLabel(_address)})',
          serum.isEmpty ? StepResult.fail : StepResult.info,
          detail: [
            'Bulunan kartlar: ${cards.map((c) => 'satır ${c.rowAddress} → ${c.rawTypeResponse.trim()}').join(', ')}',
            'Serum (250) satırları: ${serum.isEmpty ? '-' : serum.map((c) => c.rowAddress).join(', ')}',
            defInfo,
          ].join('\n'),
        );

    if (!mounted) return;
    setState(() {
      _finding = false;
      _serumCards = serum;
      _definitionInfo = defInfo;
    });
  }

  // ── 2. Kapak keşfi ────────────────────────────────────────────

  Future<void> _runProbe() async {
    final row = _row;
    if (row == null) return showMessage(context, 'Önce satır girin.', error: true);
    _stopWatch();
    setState(() {
      _probing = true;
      _probe.clear();
    });

    if (!await _selectRow(row)) {
      ref.read(testReportProvider).add('Serum kapak keşfi ($_where)', StepResult.fail, detail: 'Satır seçilemedi.');
      if (mounted) {
        setState(() => _probing = false);
        showMessage(context, 'Satır $row seçilemedi.', error: true);
      }
      return;
    }

    for (final a in _scheme.addresses) {
      final results = <DeviceAction, String?>{};
      for (final action in _probeActions) {
        results[action] = await _send(action, a);
      }
      if (!mounted) return;
      setState(() => _probe[a] = results);
    }
    await _release();

    final alive = _probe.entries.where((e) => e.value.values.any(_isAlive)).map((e) => e.key.label).toList();
    final lines = [
      'Şema: ${_scheme.title}',
      for (final e in _probe.entries)
        '${e.key.label}: '
            '${_probeActions.map((act) => '${act.code}=${_payload(e.value[act]) ?? '—'}').join('  ')}',
      'Cevap veren adresler: ${alive.isEmpty ? '-' : alive.join(', ')}',
    ];
    ref.read(testReportProvider).add('Serum kapak keşfi ($_where)', StepResult.info, detail: lines.join('\n'));
    if (mounted) setState(() => _probing = false);
  }

  // ── 3. Aç + eşleştir ──────────────────────────────────────────

  Future<void> _open() async {
    final row = _row;
    if (row == null) return showMessage(context, 'Önce satır girin.', error: true);
    _stopWatch();
    final target = _target;
    setState(() {
      _opening = true;
      _openResult = null;
    });

    String? raw;
    final selected = await _selectRow(row);
    if (selected) raw = await _send(DeviceAction.open, target, timeout: const Duration(milliseconds: 2500));
    final accepted = _payload(raw) == 'ok' || _payload(raw) == 'h3';
    final result = !selected ? 'Satır seçilemedi' : '${_payload(raw) ?? 'cevap yok'} → ${_meaning(raw)}';

    ref
        .read(testReportProvider)
        .add(
          'Serum kapak aç ($_where, ${target.label})',
          accepted ? StepResult.info : StepResult.fail,
          detail: result,
        );

    if (!mounted) return;
    setState(() {
      _opening = false;
      _openResult = result;
      _awaitingObservation = selected ? target : null;
    });
    if (accepted) _startWatch();
  }

  void _startWatch() {
    final row = _row;
    if (row == null) return;
    final target = _target;
    _watchTimer?.cancel();
    _watchTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_polling || !mounted) return;
      _polling = true;
      try {
        if (await _selectRow(row)) {
          final raw = await _send(DeviceAction.status, target);
          if (mounted) setState(() => _targetStatus = raw);
        }
      } finally {
        _polling = false;
      }
    });
    setState(() {});
  }

  void _stopWatch() {
    if (_watchTimer == null) return;
    _watchTimer?.cancel();
    _watchTimer = null;
    _release();
    if (mounted) setState(() {});
  }

  void _observe(String what) {
    final a = _awaitingObservation;
    if (a == null) return;
    ref
        .read(testReportProvider)
        .add(
          'Gözlem: $_where, ${a.label} → $what',
          what == 'Hiçbiri' || what == 'Birden fazla' ? StepResult.fail : StepResult.ok,
        );
    setState(() {
      _mapping[a] = what;
      _awaitingObservation = null;
    });
  }

  void _reportMapping() {
    ref
        .read(testReportProvider)
        .add(
          'Serum adres → kapak eşleşmesi ($_where)',
          StepResult.info,
          detail: _mapping.entries.map((e) => '${e.key.label} → ${e.value}').join('\n'),
        );
    showMessage(context, 'Eşleşme tablosu rapora eklendi.');
  }

  // ── 4. Kapak testi (client komutuyla) ─────────────────────────

  /// Client'taki serum açma yolu: `openMasterSerumDrawer(row, port: kapak)`.
  Future<void> _openLid(int lid) async {
    final row = _row;
    if (row == null) return showMessage(context, 'Önce satır girin.', error: true);
    _stopWatch();
    setState(() {
      _lidBusy = lid;
      _lidResult.remove(lid);
      _lidConfirmed.remove(lid);
    });
    String result;
    try {
      await ref.read(cabinOpsProvider).openMasterSerumDrawer(manager: _manager, row: row, port: lid);
      result = 'Açma komutu kabul edildi';
    } catch (e) {
      result = 'HATA: $e';
    }
    await _release();
    ref
        .read(testReportProvider)
        .add(
          'Serum kapak $lid aç — client komutu ($_where, port $lid)',
          result.startsWith('HATA') ? StepResult.fail : StepResult.info,
          detail: result,
        );
    if (!mounted) return;
    setState(() {
      _lidBusy = null;
      _lidResult[lid] = result;
    });
  }

  void _confirmLid(int lid, bool opened) {
    ref
        .read(testReportProvider)
        .add(
          'Gözlem: kapak $lid ${opened ? 'açıldı' : 'AÇILMADI'} ($_where)',
          opened ? StepResult.ok : StepResult.fail,
        );
    setState(() => _lidConfirmed[lid] = opened);
  }

  // ── UI ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final connected = ref.watch(sessionProvider.select((s) => s.port != null));
    final idle = connected && !_finding && !_probing && !_opening;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _findSection(connected, idle),
        _probeSection(idle),
        _openSection(connected, idle),
        _lidTestSection(idle),
        TrayLockSection(address: _address, row: _row, idle: idle && _lidBusy == null),
      ],
    );
  }

  Widget _findSection(bool connected, bool idle) {
    final cards = _serumCards;
    return SectionCard(
      title: '1. Serum kartını bul',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seçilen yönetim kartında satır 01–26 taranır, tip 250 dönen kartlar listelenir. '
            'Kart biliniyorsa satırı elle de girebilirsiniz.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Yönetim kartı:'),
              AddressPicker(
                value: _address,
                onChanged: (v) {
                  _stopWatch();
                  setState(() => _address = v);
                },
              ),
              BusyButton(
                label: 'Serum kartını bul',
                icon: Icons.search,
                busy: _finding,
                onPressed: idle ? _findCards : null,
              ),
              NumberField(label: 'Satır', controller: _rowCtrl, width: 90),
              if (!connected) const Text('Önce COM porta bağlanın.', style: TextStyle(color: Colors.red)),
            ],
          ),
          if (cards != null) ...[
            const SizedBox(height: 12),
            Text(
              cards.isEmpty
                  ? 'Tip 250 dönen kart bulunamadı.'
                  : 'Serum kartı satırları: ${cards.map((c) => c.rowAddress).join(', ')}',
              style: TextStyle(fontWeight: FontWeight.w600, color: cards.isEmpty ? Colors.red.shade700 : null),
            ),
          ],
          if (_definitionInfo != null) ...[
            const SizedBox(height: 6),
            Text('Servis tanımı (client taramada bu göz sayısını kullanır):\n$_definitionInfo'),
          ],
        ],
      ),
    );
  }

  Widget _probeSection(bool idle) {
    const mono = TextStyle(fontFamily: 'Consolas', fontSize: 12);
    return SectionCard(
      title: '2. Kapak keşfi (açma komutu göndermez)',
      trailing: BusyButton(
        label: 'Keşfi başlat',
        icon: Icons.radar,
        busy: _probing,
        onPressed: idle && _row != null ? _runProbe : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Her adrese M (orada mısın), V (tip) ve S (durum) gönderilir. Kapak takılı adreslerin '
            'boş adreslerden farklı cevap verip vermediğine bakın.',
          ),
          const SizedBox(height: 8),
          SegmentedButton<_Scheme>(
            segments: [
              for (final s in _Scheme.values)
                ButtonSegment(value: s, label: Text(s.title), tooltip: s.hint),
            ],
            selected: {_scheme},
            onSelectionChanged: idle ? (v) => setState(() => _scheme = v.first) : null,
          ),
          if (_probe.isNotEmpty) ...[
            const SizedBox(height: 12),
            DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              columns: [
                const DataColumn(label: Text('Adres')),
                for (final a in _probeActions) DataColumn(label: Text(a.code)),
                const DataColumn(label: Text('Sonuç')),
              ],
              rows: [
                for (final e in _probe.entries)
                  DataRow(
                    cells: [
                      DataCell(Text(e.key.label)),
                      for (final a in _probeActions)
                        DataCell(
                          Tooltip(
                            message: _meaning(e.value[a]),
                            child: Text(_payload(e.value[a]) ?? '—', style: mono),
                          ),
                        ),
                      DataCell(
                        ResultBadge(
                          result: e.value.values.any(_isAlive) ? StepResult.ok : StepResult.info,
                          label: e.value.values.any(_isAlive)
                              ? 'cevap var · ${_meaning(e.value[DeviceAction.status])}'
                              : 'cevap yok',
                        ),
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

  Widget _openSection(bool connected, bool idle) {
    final watching = _watchTimer != null;
    final status = _targetStatus;
    final statusColor = status == null
        ? Colors.grey.shade600
        : _isOpen(status)
        ? Colors.orange.shade700
        : Colors.green.shade700;
    return SectionCard(
      title: '3. Kapak aç ve eşleştir',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bir adres seçip açın, sonra fiziksel olarak hangi kapağın açıldığını işaretleyin. '
            'Böylece adres → kapak tablosu çıkar.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<_LidAddress>(
                value: _target,
                items: [
                  for (final s in _Scheme.values)
                    for (final a in s.addresses) DropdownMenuItem(value: a, child: Text(a.label)),
                ],
                onChanged: idle
                    ? (v) {
                        if (v == null) return;
                        _stopWatch();
                        setState(() {
                          _target = v;
                          _targetStatus = null;
                        });
                      }
                    : null,
              ),
              BusyButton(
                label: 'Aç',
                icon: Icons.lock_open,
                busy: _opening,
                onPressed: idle && _row != null ? _open : null,
              ),
              OutlinedButton.icon(
                onPressed: connected && _row != null ? (watching ? _stopWatch : _startWatch) : null,
                icon: Icon(watching ? Icons.visibility_off : Icons.visibility),
                label: Text(watching ? 'İzlemeyi durdur' : 'Durumu izle (1 sn)'),
              ),
            ],
          ),
          if (_openResult != null) ...[
            const SizedBox(height: 8),
            Text('Açma cevabı: $_openResult'),
          ],
          if (watching || status != null) ...[
            const SizedBox(height: 4),
            Text(
              'Durum: ${_payload(status) ?? '—'} → ${_meaning(status)}',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ],
          if (_awaitingObservation != null) ...[
            const SizedBox(height: 12),
            Text('${_awaitingObservation!.label} açıldı. Hangi kapak açıldı?'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final l in ['Kapak 1', 'Kapak 2', 'Kapak 3', 'Kapak 4', 'Hiçbiri', 'Birden fazla'])
                  ActionChip(label: Text(l), onPressed: () => _observe(l)),
              ],
            ),
          ],
          if (_mapping.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Eşleşme tablosu', style: Theme.of(context).textTheme.titleSmall),
            for (final e in _mapping.entries) Text('${e.key.label} → ${e.value}'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _reportMapping,
              icon: const Icon(Icons.playlist_add_check),
              label: const Text('Tabloyu rapora ekle'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _lidTestSection(bool idle) {
    return SectionCard(
      title: '4. Kapak testi (client komutuyla)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client\'ın serum kapağı açarken kullandığı komutla (kapak N → port N · göz 00) kapaklar tek tek '
            'açılır. Her kapaktan sonra kapağın açılıp açılmadığını onaylayın.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Kapak sayısı:'),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _lidCount,
                items: [
                  for (var n = 1; n <= DeviceConstants.maxSerumLids; n++)
                    DropdownMenuItem(value: n, child: Text('$n')),
                ],
                onChanged: idle ? (v) => setState(() => _lidCount = v ?? _lidCount) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var lid = 1; lid <= _lidCount; lid++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(width: 150, child: Text('Kapak $lid (port $lid)')),
                  BusyButton(
                    label: 'Aç',
                    icon: Icons.lock_open,
                    busy: _lidBusy == lid,
                    onPressed: idle && _lidBusy == null && _row != null ? () => _openLid(lid) : null,
                  ),
                  if (_lidResult[lid] != null) Text(_lidResult[lid]!),
                  if (_lidResult[lid] != null && _lidConfirmed[lid] == null) ...[
                    ActionChip(label: const Text('Açıldı'), onPressed: () => _confirmLid(lid, true)),
                    ActionChip(label: const Text('Açılmadı'), onPressed: () => _confirmLid(lid, false)),
                  ],
                  if (_lidConfirmed[lid] != null)
                    ResultBadge(
                      result: _lidConfirmed[lid]! ? StepResult.ok : StepResult.fail,
                      label: _lidConfirmed[lid]! ? 'açıldı' : 'açılmadı',
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
