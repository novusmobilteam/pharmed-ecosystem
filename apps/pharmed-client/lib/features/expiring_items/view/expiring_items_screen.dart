import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:provider/provider.dart';

import '../notifier/expiring_items_notifier.dart';

part 'table_view.dart';

class ExpiringItemsScreen extends StatelessWidget {
  const ExpiringItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExpiringItemsNotifier>(
      create: (ctx) => ExpiringItemsNotifier(useCase: ctx.read()),
      child: const _ExpiringItemsContent(),
    );
  }
}

class _ExpiringItemsContent extends StatelessWidget {
  const _ExpiringItemsContent();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ExpiringItemsNotifier>();

    Widget body;
    if (notifier.isTableLoading && notifier.items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (notifier.isFailed(notifier.loadOp) && notifier.items.isEmpty) {
      body = const Center(child: EmptyStateWidget(variant: EmptyStateVariant.noResults));
    } else {
      body = TableView(items: notifier.items, isLoading: notifier.isTableLoading, notifier: notifier);
    }

    return Scaffold(body: body);
  }
}
