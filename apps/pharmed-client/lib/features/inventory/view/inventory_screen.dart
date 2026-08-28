import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/inventory_notifier.dart';
import '../notifier/inventory_state.dart';

part 'table_view.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryNotifierProvider);
    final notifier = ref.read(inventoryNotifierProvider.notifier);

    return Scaffold(
      body: switch (state) {
        InventoryLoading() => const Center(child: MedLoadingIndicator()),
        InventoryLoaded(:final items, :final isLoading) => TableView(
          items: items,
          isLoading: isLoading,
          notifier: notifier,
        ),
        InventoryError() => Center(child: EmptyStateWidget(variant: EmptyStateVariant.noResults)),
      },
    );
  }
}
