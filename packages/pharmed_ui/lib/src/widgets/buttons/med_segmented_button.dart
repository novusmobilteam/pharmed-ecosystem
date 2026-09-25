import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class MedSegmentedButton extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;
  final List<String> labels;

  const MedSegmentedButton({super.key, required this.selectedIndex, required this.onChanged, required this.labels});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final activeTextColor = MedColors.text;
    final inactiveTextColor = MedColors.text3;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: MedColors.border.withAlpha(90),
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border, width: 1.5),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: MedColors.border),
                    // boxShadow: [
                    //   BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2)),
                    // ],
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
                          style: theme.textTheme.bodySmall!.copyWith(
                            fontFamily: MedFonts.sans,
                            color: isSelected ? activeTextColor : inactiveTextColor,
                          ),
                          child: Text(
                            labels[index],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MedTextStyles.bodyMd(
                              color: isSelected ? activeTextColor : inactiveTextColor,
                            ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
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
