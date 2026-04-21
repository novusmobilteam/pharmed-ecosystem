// lib/l10n/l10n_ext.dart
//
// BuildContext.l10n convenience getter.
// Usage: context.l10n.someKey

import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

extension L10nExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
