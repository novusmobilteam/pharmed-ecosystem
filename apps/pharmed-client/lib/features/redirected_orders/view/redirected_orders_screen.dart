import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/redirected_orders_notifier.dart';

part 'table_view.dart';

class RedirectedOrdersScreen extends StatelessWidget {
  const RedirectedOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MedResponsiveLayout(
      mobile: const MedMobileLayout(),
      tablet: const MedTabletLayout(),
      desktop: Center(
        //actions: [],
        child: TableView(),
      ),
    );
  }
}
