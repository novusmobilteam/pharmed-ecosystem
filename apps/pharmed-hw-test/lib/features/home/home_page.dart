import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cabin_session.dart';
import '../../core/cabin_type.dart';
import '../../core/providers.dart';
import '../../core/report.dart';
import '../../core/scenarios.dart';
import '../../core/serum_definition.dart';
import '../../widgets/common.dart';
import '../advanced/advanced_page.dart';
import '../cabin/cabin_page.dart';
import '../connection/connection_page.dart';
import '../drawer_test/drawer_test_page.dart';
import '../mobile_cabin/mobile_cabin_page.dart';
import '../peripherals/peripherals_page.dart';
import '../report/report_page.dart';
import '../rfid/rfid_page.dart';
import '../serum/serum_page.dart';
import '../tests/tests_page.dart';
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
  static const _tests = (icon: Icons.checklist, label: 'Testler', page: TestsPage());
  static const _masterDrawer = (icon: Icons.inventory_2, label: 'Master çekmece', page: DrawerTestPage());
  static const _mobileCabin = (icon: Icons.local_shipping, label: 'Mobil kabin', page: MobileCabinPage());
  static const _serum = (icon: Icons.water_drop, label: 'Serum', page: SerumPage());
  static const _rfid = (icon: Icons.sensors, label: 'RFID', page: RfidPage());
  static const _peripherals = (icon: Icons.devices_other, label: 'Çevre birimleri', page: PeripheralsPage());
  static const _advanced = (icon: Icons.build_outlined, label: 'Gelişmiş araçlar', page: AdvancedPage());
  static const _report = (icon: Icons.description, label: 'Rapor', page: ReportPage());

  /// Menü kabin tipine göre: her tipte yalnızca o kabinle ilgili testler görünür.
  static List<({IconData icon, String label, Widget page})> _pagesFor(HwCabinType type) => switch (type) {
    HwCabinType.medicineBased => const [
      _connection,
      _cabin,
      _tests,
      _masterDrawer,
      _serum,
      _rfid,
      _peripherals,
      _advanced,
      _report,
    ],
    HwCabinType.patientBased => const [
      _connection,
      _cabin,
      _tests,
      _mobileCabin,
      _rfid,
      _peripherals,
      _advanced,
      _report,
    ],
  };

  void _changeCabinType() {
    ref.read(testReportProvider).add('Kabin tipi değiştirildi', StepResult.info);
    // Tarama sonucu kabin tipine göre yorumlandığı için sıfırlanır.
    ref.invalidate(cabinSessionProvider);
    ref.invalidate(serumDefinitionsProvider);
    ref.invalidate(scenarioResultsProvider);
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
          // Sabit 720 px pencerede menü taşmasın diye rail kaydırılabilir.
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: NavigationRail(
                    selectedIndex: index,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    destinations: [
                      for (final p in pages) NavigationRailDestination(icon: Icon(p.icon), label: Text(p.label)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(child: IndexedStack(index: index, children: [for (final p in pages) p.page])),
                // Gelişmiş araçlar trafik panelini sekmeye göre kendisi gösterir.
                if (pages[index] != _advanced) const SizedBox(height: 220, child: TrafficPanel()),
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
