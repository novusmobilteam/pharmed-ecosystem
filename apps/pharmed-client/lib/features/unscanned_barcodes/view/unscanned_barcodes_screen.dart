import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:provider/provider.dart';

import '../notifier/unscanned_barcodes_notifier.dart';

part 'table_view.dart';

class UnscannedBarcodesScreen extends StatelessWidget {
  const UnscannedBarcodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UnscannedBarcodesNotifier>(
      create: (ctx) => UnscannedBarcodesNotifier(useCase: ctx.read()),
      child: const _UnscannedBarcodesContent(),
    );
  }
}

class _UnscannedBarcodesContent extends StatelessWidget {
  const _UnscannedBarcodesContent();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<UnscannedBarcodesNotifier>();

    Widget body;
    if (notifier.isTableLoading && notifier.items.isEmpty) {
      body = const Center(child: MedLoadingIndicator());
    } else if (notifier.isFailed(notifier.loadOp) && notifier.items.isEmpty) {
      body = const Center(child: EmptyStateWidget(variant: EmptyStateVariant.noResults));
    } else {
      body = TableView(items: notifier.items, isLoading: notifier.isTableLoading, notifier: notifier);
    }

    return Scaffold(body: body);
  }
}
