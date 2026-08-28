import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension DateRangePresetL10n on DateRangePreset {
  String label(AppLocalizations l10n) => switch (this) {
    DateRangePreset.today => l10n.dateFilter_tomorrowPreset,
    DateRangePreset.last3Days => l10n.dateFilter_last3DaysPreset,
    DateRangePreset.last7Days => l10n.dateFilter_last7DaysPreset,
    DateRangePreset.all => l10n.dateFilter_allPreset,
  };
}
