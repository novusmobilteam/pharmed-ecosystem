import 'package:flutter/widgets.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Sol panelde (hasta listesi, dolum listesi vb.) henüz bir seçim yapılmadığında
/// sağ panelde gösterilen boş durum görünümü.
class EmptySelectionView extends StatelessWidget {
  const EmptySelectionView({super.key, required this.title, required this.description, this.icon});

  final String title;
  final String description;

  /// Hedef kutucuğundaki ikon. Varsayılan: hasta seçimi (userPlus).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              spacing: 12.0,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _ListSkeleton(),
                Icon(PhosphorIcons.arrowRight(), color: MedColors.blueLight2),
                Container(
                  width: 70,
                  height: 85,
                  decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.mdAll),
                  child: Icon(icon ?? PhosphorIcons.userPlus(), color: MedColors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(title, style: MedTextStyles.titleMd(), textAlign: TextAlign.center),
            const SizedBox(height: 6.0),
            Text(description, style: MedTextStyles.bodySm(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, Color color) => Container(
      width: width,
      height: 15,
      decoration: BoxDecoration(color: color, borderRadius: MedRadius.midAll),
    );

    return Column(
      spacing: 4.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [bar(100, MedColors.border), bar(80, MedColors.border2), bar(100, MedColors.border)],
    );
  }
}
