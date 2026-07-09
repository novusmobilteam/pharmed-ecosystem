import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../auth/notifier/auth_notifier.dart';
import '../../../home/notifier/home_notifier.dart';
import '../notifier/settings_notifier.dart';

// Manager
part 'cabin_settings_view.dart';
// Admin
part 'developer_settings_view.dart';
part 'general_settings_view.dart';
part 'prescription_settings_view.dart';

void showSettingsView(BuildContext context) {
  showDialog(context: context, builder: (context) => SettingsView());
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final auth = context.watch<AuthNotifier>();
    final isAdmin = auth.currentUser?.isAdmin ?? false;

    final List<String> currentTitles = [];
    final List<Widget> currentViews = [];

    // Manager Modu veya Admin ise bu ayarları göster
    if (settings.currentMode == AppMode.manager || isAdmin) {
      currentTitles.addAll([context.l10n.settingsView_cabinTabTitle, context.l10n.settingsView_prescriptionTabTitle]);
      currentViews.addAll([const CabinSettingsView(), const PrescriptionSettingsView()]);
    }

    // Herkesin gördüğü Genel Ayarlar
    currentTitles.add(context.l10n.settingsView_generalTabTitle);
    currentViews.add(const GeneralSettingsView());

    // SADECE ADMİN ise Geliştirici Ayarlarını ekle
    if (isAdmin) {
      currentTitles.add(context.l10n.settingsView_developerTabTitle);
      currentViews.add(DeveloperSettingsView(settings: settings));
    }

    return Consumer<SettingsNotifier>(
      builder: (context, notifier, _) {
        return CustomDialog(
          title: context.l10n.settings_title,
          isLoading: notifier.isSubmitting,
          child: Column(
            spacing: 20,
            children: [
              MedSegmentedButton(
                selectedIndex: activeIndex,
                onChanged: (index) => setState(() => activeIndex = index),
                labels: currentTitles, // Dinamik liste
              ),
              Expanded(
                child: IndexedStack(
                  index: activeIndex,
                  children: currentViews, // Dinamik liste
                ),
              ),
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.read<HomeNotifier>().fetchMenus(),
                    child: Text(context.l10n.settingsView_refreshPermissionsButton),
                  ),
                  Spacer(),
                  MedButton(onPressed: () {}, label: context.l10n.common_cancelButton),
                  MedButton(
                    label: context.l10n.common_saveButton,
                    onPressed: () {
                      notifier.saveAllChanges(
                        onFailed: (message) => MessageUtils.showErrorSnackbar(context, message),
                        onSuccess: (message) =>
                            MessageUtils.showSuccessSnackbar(context, message ?? context.l10n.settings_updateSuccessMessage),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
