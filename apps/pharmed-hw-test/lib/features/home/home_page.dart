import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../card_scan/card_scan_page.dart';
import '../connection/connection_page.dart';
import '../console/console_page.dart';
import '../drawer_test/drawer_test_page.dart';
import '../line_scan/line_scan_page.dart';
import '../report/report_page.dart';
import 'traffic_panel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;

  static const _pages = <({IconData icon, String label, Widget page})>[
    (icon: Icons.usb, label: 'Bağlantı', page: ConnectionPage()),
    (icon: Icons.lan, label: 'Hat taraması', page: LineScanPage()),
    (icon: Icons.view_list, label: 'Kart taraması', page: CardScanPage()),
    (icon: Icons.inventory_2, label: 'Çekmece testi', page: DrawerTestPage()),
    (icon: Icons.terminal, label: 'Konsol', page: ConsolePage()),
    (icon: Icons.description, label: 'Rapor', page: ReportPage()),
  ];

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final connected = session.port != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PharMed Donanım Testi'),
        actions: [
          _InfoChip(icon: Icons.person, text: session.user?.fullName ?? '-'),
          _InfoChip(icon: Icons.apartment, text: session.station?.title ?? 'İstasyon seçilmedi'),
          _InfoChip(
            icon: connected ? Icons.link : Icons.link_off,
            text: connected ? (session.port ?? 'Bağlı') : 'Bağlı değil',
            color: connected ? Colors.green.shade700 : Colors.red.shade700,
          ),
          IconButton(
            tooltip: 'Çıkış',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final serial = ref.read(serialServiceProvider);
              if (serial.isConnected) await serial.disconnect();
              ref.read(tokenHolderProvider).setToken(null);
              ref.read(sessionProvider.notifier).logout();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              for (final p in _pages) NavigationRailDestination(icon: Icon(p.icon), label: Text(p.label)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(child: IndexedStack(index: _index, children: [for (final p in _pages) p.page])),
                if (_index != 4) const SizedBox(height: 220, child: TrafficPanel()),
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
