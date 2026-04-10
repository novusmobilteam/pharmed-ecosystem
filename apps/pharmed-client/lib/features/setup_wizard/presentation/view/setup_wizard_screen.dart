// [SWREQ-SETUP-UI-016] [IEC 62304 §5.
// Setup Wizard ana ekranı.
// Sol panel: 5 adımlı sidebar. Sağ panel: aktif adım widget'ı.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/setup/app_setup_notifier.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../notifier/setup_wizard_notifier.dart';
import '../state/setup_wizard_ui_state.dart';
import 'steps/step1/step1_cabin_type.dart';
import 'steps/step2/step2_basic_info.dart';
import 'steps/step3/step3_station_scope.dart';
import 'steps/step4/step4_drawer_config.dart';
import 'steps/step5/step5_summary.dart';

part 'widgets/sidebar_view.dart';
part 'widgets/wizard_scren_state_views.dart';

class SetupWizardScreen extends ConsumerWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(setupWizardNotifierProvider);

    return Scaffold(
      backgroundColor: MedColors.bg,
      body: Column(
        children: [
          Expanded(
            child: switch (uiState) {
              WizardActive() => WizardActiveView(state: uiState),
              WizardSaving() => const _WizardSavingView(),
              WizardSaved(:final cabinId, :final cabinName) => WizardSuccessView(
                cabinId: cabinId,
                cabinName: cabinName,
              ),
              WizardSaveError(:final message) => WizardErrorView(message: message),
            },
          ),
        ],
      ),
    );
  }
}
