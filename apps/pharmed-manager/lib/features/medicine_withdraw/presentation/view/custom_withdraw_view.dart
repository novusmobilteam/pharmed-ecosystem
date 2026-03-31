import 'package:flutter/material.dart';
import '../../../cabin/shared/cabin_process/notifier/cabin_status_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../cabin/shared/cabin_process/view/cabin_process_wrapper.dart';
import '../../../hospitalization/domain/entity/hospitalization.dart';
import '../../domain/entity/withdraw_item.dart';
import '../widgets/custom_withdraw_item_card.dart';
import '../notifier/custom_withdraw_notifier.dart';

part 'custom_withdraw_confirm_dialog.dart';

class PatientMedicineWithdrawView extends StatefulWidget {
  const PatientMedicineWithdrawView({super.key, required this.hospitalization});

  final Hospitalization hospitalization;

  @override
  State<PatientMedicineWithdrawView> createState() => _PatientMedicineWithdrawViewState();
}

class _PatientMedicineWithdrawViewState extends State<PatientMedicineWithdrawView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CustomWithdrawNotifier(
        hospitalization: widget.hospitalization,
        getPatientMedicinesUseCase: context.read(),
        withdrawPatientMedicineUseCase: context.read(),
      )..getItems(),
      child: Consumer<CustomWithdrawNotifier>(
        builder: (context, vm, _) {
          return CabinProcessWrapper(
            onDrawerReady: (context, activeDrawer) async {
              final currentItem = vm.selectedItem;
              if (currentItem == null) return false;

              final bool? result = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => CustomWithdrawConfirmDialog(item: currentItem),
              );

              if (result == true) {
                vm.submit(
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
                );
                return true;
              }

              return false;
            },
            child: CustomDialog(
              title: 'Hasta İlaç Alım',
              maxHeight: context.height * 0.8,
              width: context.width * 0.5,
              child: _buildChild(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChild() {
    return Consumer<CustomWithdrawNotifier>(
      builder: (context, vm, _) {
        if (vm.isFetching && vm.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (vm.isEmpty) {
          return Center(child: CommonEmptyStates.noData());
        }

        return ListView.builder(
          itemCount: vm.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = vm.items.elementAt(index);
            final isSelected = vm.selectedItem == item;
            final isCompleted =
                item.prescriptionItem?.applicationDate != null && item.prescriptionItem?.applicationUser != null;

            return CustomWithdrawItemCard(
              item: item,
              isCompleted: isCompleted,
              isSelected: isSelected,
              onTap: () {
                if (!isCompleted && item.assignment != null) {
                  vm.selectItem(item);

                  //context.read<CabinStatusNotifier>().startOperation(item.assignment!);
                }
              },
            );
          },
        );
      },
    );
  }
}
