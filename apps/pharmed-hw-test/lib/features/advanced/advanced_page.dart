import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/cabin_type.dart';
import '../../core/providers.dart';
import '../../widgets/common.dart';
import '../card_scan/card_scan_page.dart';
import '../console/console_page.dart';
import '../home/traffic_panel.dart';
import '../line_scan/line_scan_page.dart';
import '../serum_cabin/serum_cabin_page.dart';

/// Arıza teşhisi araçları: ham hat / kart taraması, serum kapak keşfi ve
/// avadanlık kilit kartı elle komutları, konsol. Günlük testte gerekmez;
/// herkes görebilir.
class AdvancedPage extends ConsumerStatefulWidget {
  const AdvancedPage({super.key});

  @override
  ConsumerState<AdvancedPage> createState() => _AdvancedPageState();
}

class _AdvancedPageState extends ConsumerState<AdvancedPage> {
  int _tab = 0;

  static const _lineScan = (label: 'Hat taraması', page: LineScanPage(), console: false);
  static const _cardScan = (label: 'Kart taraması', page: CardScanPage(), console: false);
  static const _serum = (label: 'Serum keşfi ve kilit kartı', page: SerumCabinPage(), console: false);
  static const _console = (label: 'Konsol', page: ConsolePage(), console: true);

  static List<({String label, Widget page, bool console})> _tabsFor(HwCabinType? type) => switch (type) {
    HwCabinType.patientBased => const [_lineScan, _console],
    _ => const [_lineScan, _cardScan, _serum, _console],
  };

  @override
  Widget build(BuildContext context) {
    final type = ref.watch(sessionProvider.select((s) => s.cabinType));
    final tabs = _tabsFor(type);
    final index = _tab < tabs.length ? _tab : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: MedColors.amberLight,
          padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl2, vertical: MedSpacing.md),
          child: Row(
            children: [
              Icon(TestStatus.warning.icon, size: 18, color: TestStatus.warning.color),
              const SizedBox(width: MedSpacing.md),
              const Expanded(
                child: Text(
                  'Arıza teşhisi için ham araçlar. Günlük test için Kabin, Testler ve Serum sayfalarını kullanın.',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(MedSpacing.xl2, MedSpacing.lg, MedSpacing.xl2, 0),
          child: Wrap(
            spacing: MedSpacing.md,
            children: [
              for (var i = 0; i < tabs.length; i++)
                ChoiceChip(
                  label: Text(tabs[i].label),
                  selected: i == index,
                  onSelected: (_) => setState(() => _tab = i),
                ),
            ],
          ),
        ),
        Expanded(child: IndexedStack(index: index, children: [for (final t in tabs) t.page])),
        // Konsolun kendi trafik paneli var.
        if (!tabs[index].console) const SizedBox(height: 220, child: TrafficPanel()),
      ],
    );
  }
}
