import 'package:flutter/material.dart';

class Lockable extends StatelessWidget {
  const Lockable({super.key, required this.locked, required this.child});

  final bool locked;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;

    // Focus’a da izin vermeyelim (klavye, tab vs.)
    return FocusScope(
      canRequestFocus: false,
      child: IgnorePointer(
        // görünüm değişmez, sadece tıklamalar engellenir
        ignoring: true,
        child: child,
      ),
    );
  }
}
