import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/unscanned_barcodes_notifier.dart';
import '../notifier/unscanned_barcodes_state.dart';
import 'scan_barcode_dialog.dart';

part 'table_view.dart';

class UnscannedBarcodesScreen extends ConsumerWidget {
  const UnscannedBarcodesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(unscannedBarcodesNotifierProvider);
    final notifier = ref.read(unscannedBarcodesNotifierProvider.notifier);

    return Scaffold(
      body: switch (state) {
        UnscannedBarcodesLoading() => const Center(child: MedLoadingIndicator()),
        UnscannedBarcodesLoaded(:final items, :final isLoading) => TableView(
          items: items,
          isLoading: isLoading,
          notifier: notifier,
        ),
        UnscannedBarcodesError() => Center(child: EmptyStateWidget(variant: EmptyStateVariant.noResults)),
      },
    );
  }
}
