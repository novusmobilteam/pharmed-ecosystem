import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../cabin/shared/cabin_process/view/cabin_process_wrapper.dart';
import '../../cabin_stock/presentation/widgets/cabin_stock_view.dart';
import 'package:provider/provider.dart';

import '../../cabin/shared/cabin_assignment_picker/notifier/cabin_assignment_picker_notifier.dart';
import '../../cabin/shared/cabin_assignment_picker/view/cabin_assignment_picker_view.dart';

import '../../cabin/shared/cabin_inventory/view/cabin_inventory_view.dart';
import '../../cabin/shared/cabin_process/notifier/cabin_status_notifier.dart';
import '../notifier/medicine_count_notifier.dart';

class MedicineCountView extends StatefulWidget {
  const MedicineCountView({super.key});

  @override
  State<MedicineCountView> createState() => _MedicineCountViewState();
}

class _MedicineCountViewState extends State<MedicineCountView> {
  Key _stockViewKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => MedicineCountNotifier(
            countMedicineUseCase: ctx.read(),
            //onOperationRequired: (assignment) => ctx.read<CabinStatusNotifier>().startOperation(assignment),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CabinAssignmentPickerNotifier(
            getCabinAssignmetsUseCase: context.read(),
            onSave: context.read<MedicineCountNotifier>().count,
          )..getAssignments(),
        ),
      ],
      child: Consumer2<MedicineCountNotifier, CabinAssignmentPickerNotifier>(
        builder: (context, countNotifier, accordionNotifier, _) {
          return CustomDialog(
            title: 'İlaç Sayım',
            width: context.width * 0.9,
            maxHeight: context.height,
            onSearchChanged: accordionNotifier.search,
            actions: [
              if (countNotifier.showStartCountButton)
                TextButton(onPressed: () => countNotifier.startCount(), child: Text('Sayıma Başla')),
            ],
            showSearch: countNotifier.countType == MedicineCountType.medicine,
            child: Column(
              spacing: 20,
              children: [
                PharmedSegmentedButton(
                  selectedIndex: countNotifier.countTypeIndex,
                  onChanged: countNotifier.changeCountType,
                  labels: MedicineCountType.values.map((t) => t.title).toList(),
                ),
                //CabinAssignmentPickerView(type: CabinInventoryType.count),
                Expanded(child: _buildBody(context, countNotifier)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MedicineCountNotifier notifier) {
    if (notifier.countType == MedicineCountType.medicine) {
      return CabinAssignmentPickerView(type: CabinInventoryType.count);
    } else {
      return _buildStockBasedView(context, notifier);
    }
  }

  Widget _buildStockBasedView(BuildContext context, MedicineCountNotifier notifier) {
    final isCabinMode = notifier.countType == MedicineCountType.cabin;

    return CabinProcessWrapper(
      onProcessCompleted: (assignment, isSuccess) async {
        await Future.delayed(const Duration(milliseconds: 1000));

        notifier.proceedToNext();
      },
      onDrawerReady: (context, CabinAssignment initial) async {
        return await showCabinInventoryView(
          context,
          quantity: 0,
          inventoryType: CabinInventoryType.count,
          initial: initial,
          onSave: (inputs) {
            return isCabinMode
                ? notifier.cabinBasedCount(
                    inputs,
                    initial,
                    onSuccess: (msg) => _handleSuccess(notifier, msg),
                    onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  )
                : notifier.drawerBasedCount(
                    inputs,
                    initial,
                    onSuccess: (msg) => _handleSuccess(notifier, msg),
                    onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  );
          },
        );
      },
      child: CabinStockView(
        key: _stockViewKey,
        // onTapUnit: isCabinMode ? null : notifier.selectAssignment,
        // selectedAssignments: isCabinMode ? [] : notifier.selectedAssignments,
        // onDataLoaded: notifier.setAllAssignments,
      ),
    );
  }

  void _handleSuccess(MedicineCountNotifier notifier, String? message) {
    if (message == "COMPLETED") {
      MessageUtils.showSuccessSnackbar(context, "Sayım tamamlandı. Veriler güncelleniyor...");
      setState(() {
        _stockViewKey = UniqueKey();
      });
    } else {
      MessageUtils.showSuccessSnackbar(context, message);
    }
  }
}
