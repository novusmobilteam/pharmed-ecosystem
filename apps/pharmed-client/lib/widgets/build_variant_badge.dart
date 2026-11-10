// [SWREQ-CORE-002] Test sürümlerini ekranda ayırt etmek için köşe etiketi.
//
// prod + gerçek donanımda hiçbir şey çizmez. Diğer sürümlerde sol alt köşede
// küçük, tıklamayı engellemeyen bir etiket gösterir:
//   DEV · PC — sahte cihaz    (HARDWARE=mock)
//   DEV · KABİN               (HARDWARE=real)
// Teknik bir derleme etiketidir (Flutter'ın debug şeridi gibi); yerelleştirilmez.

import 'package:flutter/material.dart';

import '../core/flavor/app_flavor.dart';
import '../core/hardware/hardware_mode.dart';

class BuildVariantBadge extends StatelessWidget {
  const BuildVariantBadge({super.key, required this.child});

  final Widget child;

  static String? get label {
    final flavor = FlavorConfig.instance;
    final mockHw = HardwareConfig.isMock;
    if (flavor.isProd && !mockHw) return null;
    final name = flavor.flavor.name.toUpperCase();
    if (flavor.isMock) return '$name · sahte veri';
    return mockHw ? '$name · PC — sahte cihaz' : '$name · KABİN';
  }

  @override
  Widget build(BuildContext context) {
    final text = label;
    if (text == null) return child;
    final mockHw = HardwareConfig.isMock;
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        Positioned(
          left: 8,
          bottom: 8,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: (mockHw ? const Color(0xFF9A6205) : const Color(0xFF0D6B6E)).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  text,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
