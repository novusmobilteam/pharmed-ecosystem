import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';

class SelectionIcon extends StatelessWidget {
  const SelectionIcon({super.key, required this.isCompleted, required this.isSelected, required this.totalAmount});

  final bool isCompleted;
  final bool isSelected;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    // Eğer alım başarıyla bittiyse her zaman "Check" ikonu göster
    if (isCompleted) {
      return Icon(
        PhosphorIcons.checkCircle(),
        color: Colors.green,
      );
    }

    // Alım henüz yapılmadıysa ve stok yoksa
    if (totalAmount == 0) {
      return Icon(
        PhosphorIcons.warningCircle(), // Boş ikon yerine bir uyarı ikonu daha iyi olabilir
        color: Colors.redAccent,
      );
    }

    // Normal seçim ikonları
    if (isSelected) {
      return Icon(
        PhosphorIconsFill.circle,
        color: context.colorScheme.primary,
      );
    } else {
      return Icon(
        PhosphorIcons.circle(),
        color: context.colorScheme.primary,
      );
    }
  }
}
