import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../cabin/domain/entity/cabin_input_data.dart';
import '../../../cabin/shared/cabin_assignment_picker/notifier/cabin_assignment_picker_notifier.dart';
import '../../../cabin/shared/cabin_assignment_picker/view/cabin_assignment_picker_view.dart';

import '../../../cabin_assignment/presentation/widgets/form/cabin_assignment_form_view.dart';
import '../notifier/medicine_unload_notifier.dart';

part 'unload_confirmation_view.dart';

class MedicineUnloadView extends StatelessWidget {
  const MedicineUnloadView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              MedicineUnloadNotifier(unloadMedicineUseCase: context.read(), deleteAssignmentUseCase: context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => CabinAssignmentPickerNotifier(
            getCabinAssignmetsUseCase: context.read(),
            onSave: (inputs) async {
              return onSave(context, inputs);
            },
          )..getAssignments(),
        ),
      ],
      child: Consumer2<MedicineUnloadNotifier, CabinAssignmentPickerNotifier>(
        builder: (context, refillNotifier, accordionNotifier, _) {
          return CustomDialog(
            title: 'İlaç Boşaltma',
            width: context.width * 0.8,
            maxHeight: context.height * 0.9,
            onSearchChanged: accordionNotifier.search,
            showSearch: true,
            child: CabinAssignmentPickerView(type: CabinInventoryType.unload),
          );
        },
      ),
    );
  }
}

Future<Result> onSave(BuildContext context, List<CabinInputData> inputs) async {
  num census = 0;
  num quantity = 0;
  for (var input in inputs) {
    census = census + input.censusQuantity;
    quantity = quantity + input.quantity;
  }

  if (census == quantity) {
    await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<MedicineUnloadNotifier>(),
        child: UnloadConfirmationView(inputs: inputs, assignment: inputs.first.assignment),
      ),
    );
  } else {
    context.read<MedicineUnloadNotifier>().unloadCabin(
      inputs,
      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
      onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
    );
  }

  return Result.ok(null);
}
