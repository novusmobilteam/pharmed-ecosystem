import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedSelectionCard & MedSelectionCardGroup
// [SWREQ-UI-MOL-SCARD-001]
// Büyük seçim kartı — kabin tipi seçimi gibi görsel seçim senaryoları.
// Seçili kart: mavi border + mavi arka plan + checkmark rozeti.
// Sınıf : Class A (görsel seçim)
// ─────────────────────────────────────────────────────────────────

class MedSelectionCard extends StatelessWidget {
  const MedSelectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.minWidth = 200,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? icon;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(minWidth: minWidth),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? const [
                  BoxShadow(color: Color(0x1F1A6FD8), blurRadius: 0, spreadRadius: 3),
                  BoxShadow(color: Color(0x171E3259), blurRadius: 12, offset: Offset(0, 4)),
                ]
              : MedShadows.sm,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(height: 12)],
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: MedFonts.title,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: MedColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3, height: 1.5),
                ),
              ],
            ),
            // Checkmark rozeti
            Positioned(
              top: -6,
              right: -6,
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.elasticOut,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: MedColors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grup yardımcısı ───────────────────────────────────────────────

class MedSelectionCardItem<T> {
  const MedSelectionCardItem({required this.value, required this.title, required this.description, this.icon});
  final T value;
  final String title;
  final String description;
  final Widget? icon;
}

class MedSelectionCardGroup<T> extends StatelessWidget {
  const MedSelectionCardGroup({super.key, required this.items, required this.value, required this.onChanged});

  final List<MedSelectionCardItem<T>> items;
  final T? value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items.map((item) {
        return MedSelectionCard(
          title: item.title,
          description: item.description,
          icon: item.icon,
          isSelected: item.value == value,
          onTap: () => onChanged(item.value),
        );
      }).toList(),
    );
  }
}
