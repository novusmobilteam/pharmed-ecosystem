import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:provider/provider.dart';

import '../drug_activity.dart';

part 'table_view.dart';

class DrugActivityScreen extends StatelessWidget {
  const DrugActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DrugActivityNotifier>(
      create: (ctx) => DrugActivityNotifier(useCase: ctx.read()),
      child: const _DrugActivityContent(),
    );
  }
}

class _DrugActivityContent extends StatelessWidget {
  const _DrugActivityContent();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DrugActivityNotifier>();

    Widget body;
    if (notifier.isTableLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (notifier.errorMessage != null && notifier.items.isEmpty) {
      body = const Center(child: EmptyStateWidget(variant: EmptyStateVariant.noResults));
    } else {
      body = TableView(items: notifier.items, isLoading: notifier.isTableLoading, notifier: notifier);
    }

    return Scaffold(body: body);
  }
}
