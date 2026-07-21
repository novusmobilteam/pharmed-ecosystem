import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/core.dart';
import 'package:provider/provider.dart';

import '../notifier/auth_summary_report_notifier.dart';

part 'user_auth_summary_view.dart';
part 'table_view.dart';

class AuthSummaryReportScreen extends StatelessWidget {
  const AuthSummaryReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthSummaryReportNotifier(
        getAuthorizationSummaryUseCase: context.read(),
        getUserAuthorizationSummaryUseCase: context.read(),
      )..fetch(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          menu: menu,
          child: Consumer<AuthSummaryReportNotifier>(
            builder: (context, notifier, _) {
              return TableView(notifier: notifier);
            },
          ),
        ),
      ),
    );
  }
}

void showAuthSummaryView(BuildContext context, int userId) {
  context.read<AuthSummaryReportNotifier>().getUserSummary(userId);
  showDialog(
    context: context,
    builder: (_) =>
        ChangeNotifierProvider.value(value: context.read<AuthSummaryReportNotifier>(), child: UserAuthSummaryView()),
  );
}
