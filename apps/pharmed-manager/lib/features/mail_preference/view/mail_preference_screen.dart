import 'package:flutter/widgets.dart';
import 'package:pharmed_manager/features/mail_preference/notifier/mail_preference_notifier.dart';
import 'package:pharmed_manager/widgets/side_panel.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

part 'mail_preference_form_panel.dart';
part 'table_view.dart';

class MailPreferenceScreen extends StatelessWidget {
  const MailPreferenceScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MailPreferenceNotifier(getMailPreferences: context.read(), deleteMailPreference: context.read())
            ..getMailPreferences(),
      child: Consumer<MailPreferenceNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: MedMobileLayout(),
            tablet: MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              showAddButton: true,
              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 400,
                panel: MailPreferenceFormPanel(),
                child: TableView(notifier: notifier),
              ),
            ),
          );
        },
      ),
    );
  }
}
