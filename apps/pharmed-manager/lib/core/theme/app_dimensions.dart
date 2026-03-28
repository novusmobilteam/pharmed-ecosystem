import 'package:flutter/material.dart';

import '../core.dart';

class AppDimensions {
  AppDimensions._();

  static const EdgeInsets pagePadding = EdgeInsets.all(24.0);
  static const double registrationDialogSpacing = 20.0;

  static const pharmedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00364b), Color(0xFF01071d)],
  );

  static Decoration dialogDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      width: 1,
      color: Colors.white.withAlpha(50),
    ),
    gradient: pharmedGradient,
  );

  static BorderRadius homeCardRadius = BorderRadius.circular(12.0);

  static BorderRadius tableRadius = BorderRadius.circular(10.0);

  static Border tableBorder = Border.all(
    width: 1,
    color: Colors.white.withAlpha(50),
  );

  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: context.colorScheme.surface,
      border: Border.all(
        color: context.theme.dividerColor,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }
}
