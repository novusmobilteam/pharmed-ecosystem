// Master kabin işlem ekranlarının ortak çekmece-durumu bekleme adımı.
// Yalnızca açılmayı değil; kapanma bekleme (WaitingForClose), durdurma
// bekleme ve hata (Failed) durumlarını da kapsar — MasterCabinExecutionScaffold
// tarafından MasterDrawerStage'in TÜM dallarında kullanılır.
//
// Stage→(title, subtitle) çözümlemesi MasterCabinExecutionScaffold içinde
// yapılır (masterDrawer_status_* ARB key'leriyle, tüm ekranlarda ortak) —
// bu widget yalnızca sunumdan sorumludur, hiçbir stage tipini bilmez.

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MasterDrawerStatusView extends StatelessWidget {
  const MasterDrawerStatusView({super.key, required this.title, required this.subtitle, this.isError = false});

  final String title;
  final String subtitle;

  /// true ise (ör. MasterDrawerFailed) ikon kırmızı/amber olur ve alttaki
  /// "işleniyor" spinner'ı gösterilmez — bir hata sonsuza dek "yükleniyor"
  /// hissi vermemeli.
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final accentColor = isError ? MedColors.amber : MedColors.blue;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 90,
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              border: Border.all(color: accentColor, width: 2.5),
              borderRadius: MedRadius.lgAll,
            ),
            alignment: Alignment.center,
            child: Icon(isError ? PhosphorIcons.warning() : PhosphorIcons.dresser(), size: 46, color: accentColor),
          ),
          Text(title, style: MedTextStyles.titleLg()),
          const SizedBox(height: 6.0),
          Text(
            subtitle,
            style: MedTextStyles.bodyLg(color: MedColors.text3),
            textAlign: TextAlign.center,
          ),
          if (!isError) ...[
            const SizedBox(height: 8),
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ],
      ),
    );
  }
}
