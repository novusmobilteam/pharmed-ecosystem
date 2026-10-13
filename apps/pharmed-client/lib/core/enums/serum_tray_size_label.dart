import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Avadanlık boyutunun ekran etiketi. Enum (alan/API değeri) core'dadır.
extension SerumTraySizeLabel on SerumTraySize {
  String label(BuildContext context) => switch (this) {
    SerumTraySize.small => context.l10n.cabinDesign_serum_traySizeSmallLabel,
    SerumTraySize.medium => context.l10n.cabinDesign_serum_traySizeMediumLabel,
    SerumTraySize.large => context.l10n.cabinDesign_serum_traySizeLargeLabel,
  };
}
