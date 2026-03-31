import 'package:flutter/material.dart';

part 'mobil_cabin_visual.dart';
part 'standart_cabin_visual.dart';

enum CabinVisualType { standard, mobile }

// Factory widget — tip'e göre doğru visual döndür
class CabinVisual extends StatelessWidget {
  final CabinVisualType type;

  const CabinVisual({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      CabinVisualType.standard => const _StandardCabinVisual(),
      CabinVisualType.mobile => const _MobileCabinVisual(),
    };
  }
}
