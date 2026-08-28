import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Serum kabini rafına yerleştirilebilen avadanlık boyutları.
/// small=1, medium=2, large=4 alan kaplar (bir rafın toplam kapasitesi 8 alan).
enum TraySize { small, medium, large }

extension TraySizeX on TraySize {
  int get areaSize => switch (this) {
    TraySize.small => 1,
    TraySize.medium => 2,
    TraySize.large => 4,
  };

  String label(BuildContext context) => switch (this) {
    TraySize.small => context.l10n.cabinDesign_serum_traySizeSmallLabel,
    TraySize.medium => context.l10n.cabinDesign_serum_traySizeMediumLabel,
    TraySize.large => context.l10n.cabinDesign_serum_traySizeLargeLabel,
  };
}
