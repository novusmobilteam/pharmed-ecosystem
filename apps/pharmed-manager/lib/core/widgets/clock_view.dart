import 'package:flutter/material.dart';

enum ClockSize { mini, large }

class ClockView extends StatelessWidget {
  final ClockSize size;

  // Private constructor
  const ClockView._({super.key, required this.size});

  // Factory metodları
  factory ClockView.mini({Key? key}) => ClockView._(key: key, size: ClockSize.mini);
  factory ClockView.large({Key? key}) => ClockView._(key: key, size: ClockSize.large);

  Stream<DateTime> _clockStream() => Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DateTime>(
      stream: _clockStream(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final dateStr = "${now.day}.${now.month.toString().padLeft(2, '0')}.${now.year}";
        final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

        // Boyuta göre stil ayarları
        final bool isLarge = size == ClockSize.large;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeStr,
              style: (isLarge ? theme.textTheme.titleLarge : theme.textTheme.titleMedium)?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.0,
                fontFamily: 'Monospace',
                letterSpacing: isLarge ? -1.0 : -0.5,
              ),
            ),
            SizedBox(height: isLarge ? 4 : 2),
            Text(
              dateStr,
              style: (isLarge ? theme.textTheme.bodyMedium : theme.textTheme.labelSmall)?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: isLarge ? 12 : 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
