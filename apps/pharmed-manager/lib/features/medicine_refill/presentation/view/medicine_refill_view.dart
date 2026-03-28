import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../cabin/shared/cabin_assignment_picker/notifier/cabin_assignment_picker_notifier.dart';
import '../../../cabin/shared/cabin_assignment_picker/view/cabin_assignment_picker_view.dart';
import '../notifier/medicine_refill_notifier.dart';

class MedicineRefillView extends StatelessWidget {
  const MedicineRefillView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MedicineRefillNotifier(refillMedicineUseCase: context.read())),
        ChangeNotifierProvider(
          create: (context) => CabinAssignmentPickerNotifier(
            getCabinAssignmetsUseCase: context.read(),
            onSave: context.read<MedicineRefillNotifier>().fillCabin,
          )..getAssignments(),
        ),
      ],
      child: Consumer2<MedicineRefillNotifier, CabinAssignmentPickerNotifier>(
        builder: (context, refillNotifier, accordionNotifier, _) {
          return CustomDialog(
            title: 'İlaç Dolum',
            width: context.width * 0.8,
            maxHeight: context.height * 0.9,
            onSearchChanged: accordionNotifier.search,
            showSearch: true,
            child: CabinAssignmentPickerView(type: CabinInventoryType.refill),
          );
        },
      ),
    );
  }
}
