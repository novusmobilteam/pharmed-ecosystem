part of 'mail_preference_screen.dart';

class MailPreferenceFormPanel extends StatelessWidget {
  const MailPreferenceFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final roleNotifier = context.watch<MailPreferenceNotifier>();
    final selectedPreference = roleNotifier.selectedItem;

    return SidePanel(title: '', child: Column());
  }
}
