import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../cabin/shared/cabin_assignment_picker/notifier/cabin_assignment_picker_notifier.dart';
import '../../../cabin/shared/cabin_assignment_picker/view/cabin_assignment_picker_view.dart';

import '../../domain/entity/filling_object.dart';
import '../notifier/filling_list_view_notifier.dart';

class FillingListRefillView extends StatelessWidget {
  const FillingListRefillView({super.key});

  @override
  Widget build(BuildContext context) {
    final fillingNotifier = context.read<FillingListViewNotifier>();

    return ChangeNotifierProvider(
      create: (context) {
        final notifier = CabinAssignmentPickerNotifier(
          getCabinAssignmetsUseCase: context.read(),
          onSave: (inputs) => fillingNotifier.fillCabin(inputs, 0),
          externalAssignments: fillingNotifier.details.toCabinAssignments(),
        )..getAssignments();

        return notifier;
      },
      child: Consumer2<FillingListViewNotifier, CabinAssignmentPickerNotifier>(
        builder: (context, refillNotifier, accordionNotifier, _) {
          if (refillNotifier.isLoading(refillNotifier.fetchDetailOp)) {
            return Center(child: CircularProgressIndicator.adaptive());
          }

          return CustomDialog(
            title: 'İlaç Dolum Listesi',
            width: context.width * 0.8,
            maxHeight: context.height * 0.9,
            onSearchChanged: accordionNotifier.search,
            showSearch: true,
            child: CabinAssignmentPickerView(type: CabinInventoryType.refillList),
          );
        },
      ),
    );
  }
}
