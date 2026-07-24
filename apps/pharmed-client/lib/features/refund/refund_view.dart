import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'refund.dart';

class RefundView extends ConsumerWidget {
  const RefundView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceModeAsync = ref.watch(deviceModeProvider);

    return switch (deviceModeAsync) {
      AsyncData(:final value) => switch (value) {
        CabinType.master => MobileRefundView(menu: menu),
        CabinType.mobile => MobileRefundView(menu: menu),
        _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      },
      _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    };
  }
}
