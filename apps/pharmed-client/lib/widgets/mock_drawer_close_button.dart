// [SWREQ-CORE-006] Sahte donanımda mobil çekmeceyi elle kapatma.
//
// Bilgisayar test sürümünde (HARDWARE=mock) mobil çekmece açıkken ekranın sol
// altında "Çekmeceyi kapat" düğmesi gösterir; basınca
// ICabinOperationService.triggerManualClose() çağrılır ve mock servis
// çekmeceyi kapandı (locked) bildirir. Düğme olmadan mock çekmece ancak
// ~60 sn sonra kendiliğinden kapanıyordu.
//
// Tüm mobil işlem ekranları (dolum, alım, sayım, boşaltma …) aynı
// mobileDrawerSessionProvider'ı kullandığı için tek yerde, MaterialApp
// builder'ında durur. Gerçek donanımda hiçbir şey çizmez ve provider'ı
// dinlemez.
//
// Geliştirici/test aracıdır; metin yerelleştirilmez (BuildVariantBadge gibi).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/hardware/hardware.dart';
import '../core/hardware/hardware_mode.dart';
import '../core/providers/providers.dart';

class MockDrawerCloseOverlay extends StatelessWidget {
  const MockDrawerCloseOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!HardwareConfig.isMock) return child;
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        const Positioned(left: 8, bottom: 36, child: _MockDrawerCloseButton()),
      ],
    );
  }
}

class _MockDrawerCloseButton extends ConsumerWidget {
  const _MockDrawerCloseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(mobileDrawerSessionProvider.select((s) => s.stage is MobileDrawerOpened));
    if (!isOpen) return const SizedBox.shrink();

    return Material(
      type: MaterialType.transparency,
      child: MedButton(
        label: 'Çekmeceyi kapat (sahte)',
        size: MedButtonSize.sm,
        variant: MedButtonVariant.secondary,
        prefixIcon: Icon(PhosphorIcons.lockSimple()),
        onPressed: () {
          MedLogger.info(
            unit: 'SW-UNIT-MOCK-DRAWER',
            swreq: 'SWREQ-CORE-006',
            message: 'Mock mobil çekmece elle kapatıldı',
          );
          ref.read(cabinOperationServiceProvider).triggerManualClose();
        },
      ),
    );
  }
}
