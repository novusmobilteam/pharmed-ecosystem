import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cabin_session.dart';
import '../../core/cabin_type.dart';
import '../../core/providers.dart';
import '../../core/report.dart';
import '../../widgets/common.dart';
import '../cabin/cabin_page.dart';
import '../card_scan/card_scan_page.dart';
import '../connection/connection_page.dart';
import '../console/console_page.dart';
import '../drawer_test/drawer_test_page.dart';
import '../line_scan/line_scan_page.dart';
import '../mobile_cabin/mobile_cabin_page.dart';
import '../report/report_page.dart';
import '../rfid/rfid_page.dart';
import '../serum_cabin/serum_cabin_page.dart';
import 'traffic_panel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;

  static const _connection = (icon: Icons.usb, label: 'Bağlantı', page: ConnectionPage());
  static const _cabin = (icon: Icons.dns_outlined, label: 'Kabin', page: CabinPage());
  static const _lineScan = (icon: Icons.lan, label: 'Hat taraması', page: LineScanPage());
  static const _cardScan = (icon: Icons.view_list, label: 'Kart taraması', page: CardScanPage());
  static const _masterDrawer = (icon: Icons.inventory_2, label: 'Master çekmece', page: DrawerTestPage());
  static const _mobileCabin = (icon: Icons.local_shipping, label: 'Mobil kabin', page: MobileCabinPage());
  static const _serumCabin = (icon: Icons.water_drop, label: 'Serum kabini', page: SerumCabinPage());
  static const _rfid = (icon: Icons.sensors, label: 'RFID', page: RfidPage());
  static const _console = (icon: Icons.terminal, label: 'Konsol', page: ConsolePage());
  static const _report = (icon: Icons.description, label: 'Rapor', page: ReportPage());

  /// Menü kabin tipine göre: her tipte yalnızca o kabinle ilgili testler görünür.
  static List<({IconData icon, String label, Widget page})> _pagesFor(HwCabinType type) => switch (type) {
    HwCabinType.medicineBased => const [
      _connection,
      _cabin,
      _lineScan,
      _cardScan,
      _masterDrawer,
      _serumCabin,
      _rfid,
      _console,
      _report,
    ],
    HwCabinType.patientBased => const [_connection, _cabin, _lineScan, _mobileCabin, _rfid, _console, _report],
  };

  void _changeCabinType() {
    ref.read(testReportProvider).add('Kabin tipi değiştirildi', StepResult.info);
    // Tarama sonucu kabin tipine göre yorumlandığı için sıfırlanır.
    ref.invalidate(cabinSessionProvider);
    ref.read(sessionProvider.notifier).setCabinType(null);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final connected = session.port != null;
    final pages = _pagesFor(session.cabinType ?? HwCabinType.medicineBased);
    final index = _index < pages.length ? _index : 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PharMed Donanım Testi'),
        actions: [
          if (session.cabinType != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ActionChip(
                avatar: const Icon(Icons.swap_horiz, size: 18),
                label: Text(session.cabinType!.label),
                tooltip: 'Kabin tipini değiştir',
                onPressed: _changeCabinType,
              ),
            ),
          _InfoChip(icon: Icons.person, text: session.user?.fullName ?? '-'),
          _InfoChip(
            icon: connected ? Icons.link : Icons.link_off,
            text: connected ? (session.port ?? 'Bağlı') : 'Bağlı değil',
            color: connected ? TestStatus.passed.color : TestStatus.failed.color,
          ),
          IconButton(
            tooltip: 'Çıkış',
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              for (final p in pages) NavigationRailDestination(icon: Icon(p.icon), label: Text(p.label)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(child: IndexedStack(index: index, children: [for (final p in pages) p.page])),
                if (pages[index] != _console) const SizedBox(height: 220, child: TrafficPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Chip(avatar: Icon(icon, size: 18, color: color), label: Text(text, style: TextStyle(color: color))),
    );
  }
}
