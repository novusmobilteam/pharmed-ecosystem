import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Yatay scroll edilebilir, tek seçimli filtre chip grubu.
///
/// Touch-first ekranlar için tasarlanmıştır (44px minimum dokunma hedefi).
/// Seçenek sayısı arttığında yatay scroll devreye girer.
///
/// Generic — `T` herhangi bir tip olabilir (enum, int, String, model).
/// Eşitlik karşılaştırması `==` üzerinden yapılır.
class MedFilterChipGroup<T> extends StatelessWidget {
  const MedFilterChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labelBuilder,
    this.iconBuilder,
    this.padding = MedSpacing.xs,
    this.bgColor,
  });

  /// Seçilebilir tüm değerler. Sıralama görsel sıralamayı belirler.
  final List<T> options;

  /// Şu an seçili olan değer. `null` olamaz — bir varsayılan her zaman seçili olmalı.
  final T selected;

  /// Seçim değiştiğinde tetiklenir. Aynı chip'e tekrar dokunulursa da çağrılır
  /// (toggle davranışı istenmiyor — bu bir radio grup).
  final ValueChanged<T> onChanged;

  /// Her option için görüntülenecek metin.
  final String Function(T value) labelBuilder;

  /// Opsiyonel ikon (örn. tarih için Icons.calendar_today gibi).
  final IconData? Function(T value)? iconBuilder;

  /// Dış padding — varsayılan olarak çok az, çünkü genelde bir kart içinde kullanılır.
  final double padding;

  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MedSpacing.touchTarget.toDouble() - 10,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: MedSpacing.sm),
        itemBuilder: (context, i) {
          final option = options[i];
          final isSelected = option == selected;
          final icon = iconBuilder?.call(option);

          return _Chip(
            label: labelBuilder(option),
            icon: icon,
            isSelected: isSelected,
            onTap: () => onChanged(option),
            bgColor: bgColor,
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.isSelected, required this.onTap, this.icon, this.bgColor});

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? bgColor ?? MedColors.blue : MedColors.surface2;
    final fg = isSelected ? Colors.white : MedColors.text2;
    final border = isSelected ? bgColor ?? MedColors.blue : MedColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.lgAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: MedRadius.smAll,
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: MedSpacing.xs)],
            Text(
              label,
              style: MedTextStyles.bodyMd().copyWith(
                color: fg,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
