import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import '../notifier/expiring_items_notifier.dart';
import '../notifier/expiring_items_state.dart';

part 'table_view.dart';

class ExpiringItemsScreen extends ConsumerWidget {
  const ExpiringItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expiringItemsNotifierProvider);
    final notifier = ref.read(expiringItemsNotifierProvider.notifier);

    return Scaffold(
      body: switch (state) {
        ExpiringItemsLoading() => const Center(child: CircularProgressIndicator()),
        ExpiringItemsLoaded(:final items, :final isLoading) => TableView(
          items: items,
          isLoading: isLoading,
          notifier: notifier,
        ),
        ExpiringItemsError() => Center(child: EmptyStateWidget(variant: EmptyStateVariant.noResults)),
      },
    );
  }
}
