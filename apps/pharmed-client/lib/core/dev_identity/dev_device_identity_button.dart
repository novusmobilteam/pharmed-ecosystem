// [SWREQ-CORE-005] Aktif test cihazını gösterir, dokununca seçim ekranını açar.
// Bilgisayar test sürümü dışında hiçbir şey çizmez.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'dev_device_identity.dart';
import 'dev_device_identity_dialog.dart';

class DevDeviceIdentityButton extends StatelessWidget {
  const DevDeviceIdentityButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!DevDeviceIdentity.isAvailable) return const SizedBox.shrink();
    final name = DevDeviceIdentity.active?.name ?? 'Bu bilgisayar';
    return MedButton(
      label: 'Test cihazı: $name',
      size: MedButtonSize.sm,
      variant: MedButtonVariant.secondary,
      prefixIcon: Icon(PhosphorIcons.devices()),
      onPressed: () => showDevDeviceIdentityDialog(context),
    );
  }
}
