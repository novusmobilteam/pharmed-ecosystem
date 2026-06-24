import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension DateRangePresetL10n on DateRangePreset {
  String label(AppLocalizations l10n) => switch (this) {
    DateRangePreset.today => l10n.date_preset_today,
    DateRangePreset.last3Days => l10n.date_preset_last_3_days,
    DateRangePreset.last7Days => l10n.date_preset_last_7_days,
    DateRangePreset.all => l10n.date_preset_all,
  };
}
