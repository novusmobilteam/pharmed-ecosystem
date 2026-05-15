// lib/widgets/med_loading_indicator.dart

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Pharmed uygulaması için standart yükleme göstergesi.
///
/// ```dart
/// // Orta hizalı tam ekran
/// MedLoadingIndicator()
///
/// // Buton içi küçük spinner
/// MedLoadingIndicator(size: 18, strokeWidth: 1.5)
///
/// // Özel renk
/// MedLoadingIndicator(color: MedColors.green)
/// ```
class MedLoadingIndicator extends StatelessWidget {
  const MedLoadingIndicator({super.key, this.size = 20, this.strokeWidth = 2, this.color});

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(color ?? MedColors.blue),
      ),
    );
  }
}
