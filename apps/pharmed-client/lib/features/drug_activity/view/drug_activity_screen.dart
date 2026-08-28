import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import '../drug_activity.dart';

part 'table_view.dart';

class DrugActivityScreen extends ConsumerWidget {
  const DrugActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(drugActivityNotifierProvider);
    final notifier = ref.read(drugActivityNotifierProvider.notifier);

    return Scaffold(
      body: switch (state) {
        DrugActivityLoading() => const Center(child: CircularProgressIndicator()),
        DrugActivityLoaded(:final items, :final isLoading) => TableView(
          items: items,
          isLoading: isLoading,
          notifier: notifier,
        ),
        DrugActivityError() => Center(child: EmptyStateWidget(variant: EmptyStateVariant.noData)),
      },
    );
  }
}
