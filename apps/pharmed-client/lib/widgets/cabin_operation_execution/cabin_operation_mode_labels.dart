// widgets/cabin_shell_widgets/execution/cabin_operation_mode_labels.dart

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Giriş alanlarının etiketleri — hangi alanın VAR olduğu moddan (core),
/// nasıl etiketlendiği buradan (UI) gelir.
extension CabinOperationModeLabels on CabinOperationMode {
  String? countLabel(BuildContext context) => hasCountField ? context.l10n.refill_label_countQty : null;

  String? secondaryLabel(BuildContext context) => switch (this) {
    CabinOperationMode.refill => context.l10n.refill_label_fillQty,
    CabinOperationMode.unload => context.l10n.unload_label_unloadQty,
    CabinOperationMode.destruction => context.l10n.destruction_label_quantity,
    _ => null,
  };
}
