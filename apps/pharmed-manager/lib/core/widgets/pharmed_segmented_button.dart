import 'package:flutter/material.dart';

class PharmedSegmentedButton extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;
  final List<String> labels;

  const PharmedSegmentedButton({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    // 1. TEMA VERİLERİNİ ÇEKİYORUZ
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final trackColor = colorScheme.surfaceContainerHighest;
    final borderColor = colorScheme.outline.withValues(alpha: 0.5);
    final activeColor = colorScheme.primary;
    final activeTextColor = colorScheme.onPrimary;
    final inactiveTextColor = colorScheme.onSurface;

    return Container(
      height: 45,
      // Padding, dış container'ın içindeki boşluktur.
      // LayoutBuilder bu padding düşüldükten sonra kalan alanı hesaplar.
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth = constraints.maxWidth / labels.length;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.fastOutSlowIn,
                left: selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // YAZILAR (LABEL ROW)
              Row(
                // Yazıları eşit alana yaymak için Row kullanıyoruz
                children: List.generate(labels.length, (index) {
                  final bool isSelected = selectedIndex == index;

                  return SizedBox(
                    width: itemWidth, // Her bir yazı alanı da hesaplanan genişlikte olmalı
                    child: GestureDetector(
                      onTap: () => onChanged(index),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: theme.textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? activeTextColor : inactiveTextColor,
                          ),
                          child: Text(
                            labels[index],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
