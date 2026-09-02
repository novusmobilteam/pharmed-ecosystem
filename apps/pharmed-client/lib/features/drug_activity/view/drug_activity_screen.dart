import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import '../drug_activity.dart';

part 'table_view.dart';

class DrugActivityScreen extends ConsumerWidget {
  const DrugActivityScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
 

    return MedResponsiveLayout(
      mobile: MedMobileLayout(),
      tablet: MedTabletLayout(),
      desktop: Scaffold(body: TableView()),
    );
  }
}
