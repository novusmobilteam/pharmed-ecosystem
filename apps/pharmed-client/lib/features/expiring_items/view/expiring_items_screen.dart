import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../widgets/widgets.dart';
import '../notifier/expiring_items_notifier.dart';

part 'table_view.dart';

class ExpiringItemsScreen extends ConsumerWidget {
  const ExpiringItemsScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenTitle(menu: menu),
        const Expanded(child: TableView()),
      ],
    );
  }
}
