import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/authorization_breakdown_report_notifier.dart';

part 'table_view.dart';

class AuthorizationBreakdownReportScreen extends StatelessWidget {
  const AuthorizationBreakdownReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthorizationBreakdownReportNotifier(
        getStationsUseCase: context.read(),
        getAuthorizationBreakdownsUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<AuthorizationBreakdownReportNotifier>(
            builder: (context, notifier, _) => TableView(notifier: notifier),
          ),
        ),
      ),
    );
  }
}
