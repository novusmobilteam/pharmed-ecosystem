import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../../auth/notifier/auth_notifier.dart';
import '../drug_activity.dart';

class DrugActivityScreen extends ConsumerWidget {
  const DrugActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(drugActivityNotifierProvider);
    final notifier = ref.read(drugActivityNotifierProvider.notifier);

    return GestureDetector(
      onTap: () => ref.read(authNotifierProvider.notifier).onUserActivity(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Scaffold(
          backgroundColor: MedColors.bg,

          body: switch (state) {
            DrugActivityLoading() => const Center(child: CircularProgressIndicator()),
            DrugActivityLoaded(:final items) => MedTable(
              data: items,
              emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
              serverTotalCount: notifier.totalCount,
              currentPage: notifier.currentPage,
              pageSize: notifier.pageSize,
              enableDateFilter: true,
              onPageChanged: (page) => notifier.goToPage(page),
              onDateRangeChanged: (range) => notifier.onDateRangeChanged(range?.start, range?.end),
              cellBuilder: (item, colIndex, value) {
                if (colIndex == 6) {
                  final status = (item).type;
                  return MedInfoChip(
                    info: status.actionLabel,
                    backgroundColor: status.backgroundColor,
                    foregroundColor: status.foregroundColor,
                  );
                }
                return null;
              },
            ),
            DrugActivityError() => Center(child: EmptyStateWidget(variant: EmptyStateVariant.noResults)),
          },
        ),
      ),
    );
  }
}
