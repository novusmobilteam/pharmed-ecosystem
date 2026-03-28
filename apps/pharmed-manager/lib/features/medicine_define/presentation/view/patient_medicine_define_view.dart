import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../cabin/shared/cabin_process/notifier/cabin_status_notifier.dart';
import '../../../cabin/shared/cabin_process/view/cabin_process_wrapper.dart';
import '../../../hospitalization/domain/entity/hospitalization.dart';
import '../notifier/medicine_define_notifier.dart';

part 'slot_info_view.dart';
part 'define_confirm_dialog.dart';
part 'medicine_info_view.dart';
part 'times_row_view.dart';

class PatientMedicineDefineView extends StatelessWidget {
  const PatientMedicineDefineView({super.key, required this.hospitalization});

  final Hospitalization hospitalization;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => MedicineDefineNotifier(
        definePatientMedicineUseCase: context.read(),
        hospitalization: hospitalization,
        getSerumSlotsUseCase: context.read(),
        onDefineMedicine: (notifier) {
          context.read<CabinStatusNotifier>().startOperation(notifier.assignment);
        },
      )..getSerumSlots(),
      child: Consumer<MedicineDefineNotifier>(
        builder: (context, notifier, _) {
          return CabinProcessWrapper(
            onDrawerReady: (context, activeDrawer) async {
              final result = showDefineConfirmDialog(context);
              return result;
            },
            onProcessCompleted: (assignment, isSuccess) {
              notifier.submit(
                onFailed: (message) => MessageUtils.showErrorSnackbar(context, message),
                onSuccess: (message) {
                  MessageUtils.showSuccessSnackbar(context, message);
                  context.pop();
                },
              );
            },
            child: RegistrationDialog(
              title: 'Hasta İlacı Tanımlama',
              maxHeight: context.height * 0.8,
              width: context.width * 0.5,
              saveButtonText: notifier.saveButtonText,
              onSave: () {
                if (notifier.selectedSlot != null && notifier.compartmentNo != null) {
                  notifier.onSave(context);
                }
              },
              child: _buildChild(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChild() {
    return Consumer<MedicineDefineNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (notifier.isEmpty) {
          return Center(child: CommonEmptyStates.noData());
        }

        return IndexedStack(
          index: notifier.activeIndex,
          children: [
            SlotInfoView(),
            MedicineInfoView(),
          ],
        );
      },
    );
  }
}
