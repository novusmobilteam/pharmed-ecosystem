// Master kabin işlem ekranlarının ortak "çekmece açılıyor" bekleme adımı.
// MasterRefillExecutionPanel'deki _DrawerOpeningView'ın generic hali —
// MasterDrawerStage'i BİLEREK bilmiyor: stage→(title, subtitle) çözümlemesi
// çağıranda kalıyor, çünkü l10n key'leri işlemler arası farklı
// (refill_status_waitingPullTitle vs ileride count_status_...).

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CabinDrawerOpeningView extends StatelessWidget {
  const CabinDrawerOpeningView({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 90,
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              border: Border.all(color: MedColors.blue, width: 2.5),
              borderRadius: MedRadius.lgAll,
            ),
            alignment: Alignment.center,
            child: Icon(PhosphorIcons.dresser(), size: 46, color: MedColors.blue),
          ),
          Text(title, style: MedTextStyles.titleLg()),
          const SizedBox(height: 6.0),
          Text(
            subtitle,
            style: MedTextStyles.bodyLg(color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}
