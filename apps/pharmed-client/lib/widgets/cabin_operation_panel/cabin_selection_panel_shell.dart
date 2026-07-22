// Master kabin seçim ekranlarının (dolum, sayım...) ortak dış kabuğu.
// MasterRefillSelectionPanel'in dış Container'ından çıkarıldı — hangi
// içeriğin (ilaç grid'i, çekmece rehberi vb.) gösterileceğini bilmiyor,
// tamamen slot tabanlı.

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CabinSelectionPanelShell extends StatelessWidget {
  const CabinSelectionPanelShell({
    super.key,
    this.header,

    required this.content,
    required this.footer,
    this.maxWidth = 1300,
    required this.searchQuery,
    required this.onSearchQueryChanged,
  });

  /// Genelde [CabinSelectionHeader].
  final Widget? header;

  /// Asıl seçim alanı: ilaç grid'i, boş durum, ya da (sayımda) sol
  /// CabinLocationGuide + sağ grid kombinasyonu — tamamen çağıranın kararı.
  final Widget content;

  /// Genelde [CabinSelectionStartBar].
  final Widget footer;

  final double maxWidth;

  final String searchQuery;
  final ValueChanged<String> onSearchQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        alignment: Alignment.center,
        padding: MedSpacing.insetXl * 2,
        decoration: BoxDecoration(boxShadow: MedShadows.md, color: MedColors.surface, borderRadius: MedRadius.lgAll),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _SearchField(value: searchQuery, onChanged: onSearchQueryChanged),
            const SizedBox(height: 18),
            Expanded(child: content),
            const SizedBox(height: 18),
            footer,
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.magnifyingGlass(), color: MedColors.text3, size: 22),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                filled: false,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
