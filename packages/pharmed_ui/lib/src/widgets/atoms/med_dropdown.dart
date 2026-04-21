import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Genel amaçlı dropdown bileşeni.
///
/// Dokunmatik ekran için tasarlanmıştır — min 44px hedef alan.
/// Seçili durumda mavi, pasif durumda soluk renk kullanır.
///
/// Kullanım:
/// ```dart
/// MedDropdown<HospitalService>(
///   hint: 'Servis seçin',
///   selected: state.selectedService,
///   options: state.services,
///   labelBuilder: (s) => s.name ?? '—',
///   onSelected: notifier.onServiceSelected,
/// )
/// ```
class MedDropdown<T> extends StatelessWidget {
  const MedDropdown({
    super.key,
    required this.hint,
    required this.options,
    required this.labelBuilder,
    required this.onSelected,
    this.selected,
    this.enabled = true,
    this.height = 44,
  });

  /// Seçim yapılmadan önce gösterilecek ipucu metin.
  final String hint;

  /// Dropdown listesi.
  final List<T> options;

  /// Her öğe için gösterilecek metin.
  final String Function(T) labelBuilder;

  /// Seçim callback'i.
  final ValueChanged<T> onSelected;

  /// Seçili öğe. null ise hint gösterilir.
  final T? selected;

  /// false ise soluk görünür, tıklanamaz.
  final bool enabled;

  /// Dropdown tetikleyici yüksekliği. Varsayılan 44px (dokunmatik minimum).
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selected != null;
    final label = hasSelection ? labelBuilder(selected as T) : hint;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final Color iconColor;

    if (!enabled) {
      bgColor = MedColors.surface3;
      borderColor = MedColors.border;
      textColor = MedColors.text4;
      iconColor = MedColors.text4;
    } else if (hasSelection) {
      bgColor = MedColors.blueLight;
      borderColor = MedColors.blue;
      textColor = MedColors.blue;
      iconColor = MedColors.blue;
    } else {
      bgColor = MedColors.surface2;
      borderColor = MedColors.border;
      textColor = MedColors.text3;
      iconColor = MedColors.text3;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<T>(
          enabled: enabled && options.isNotEmpty,
          color: MedColors.surface,
          padding: EdgeInsets.zero,
          initialValue: selected,
          onSelected: onSelected,
          constraints: BoxConstraints(minWidth: constraints.maxWidth, maxWidth: constraints.maxWidth),
          offset: Offset(0, height + 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: MedColors.border, width: 1),
          ),
          elevation: 3,
          itemBuilder: (context) => options.map((item) {
            final isSelected = selected != null && labelBuilder(item) == labelBuilder(selected as T);
            return PopupMenuItem<T>(
              value: item,
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      labelBuilder(item),
                      style: TextStyle(
                        fontFamily: MedFonts.sans,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? MedColors.blue : MedColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected) Icon(Icons.check_rounded, size: 14, color: MedColors.blue),
                ],
              ),
            );
          }).toList(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 12,
                      fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w400,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: iconColor),
              ],
            ),
          ),
        );
      },
    );
  }
}
