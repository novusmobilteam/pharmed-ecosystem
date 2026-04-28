import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../cabin/shared/cabin_process/view/cabin_process_wrapper.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../../medicine_management/presentation/widgets/cabin_operation_card/cabin_operation_card.dart';
import '../notifier/medicine_refund_notifier.dart';

part 'refund_input_view.dart';
part 'refund_confirmation_view.dart';

class MedicineRefundView extends StatefulWidget {
  const MedicineRefundView({super.key, required this.hospitalization});

  final Hospitalization hospitalization;

  @override
  State<MedicineRefundView> createState() => _MedicineRefundViewState();
}

class _MedicineRefundViewState extends State<MedicineRefundView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MedicineRefundNotifier(
        hospitalization: widget.hospitalization,
        getRefundablesUseCase: context.read(),
        checkRefundStatusUseCase: context.read(),
        completeRefundUseCase: context.read(),
        onCheckCompleted: (notifier, assignment) async {
          //final bool shouldOpenLid = notifier.type == ReturnType.toOrigin; // Yerine iade ise kapak açılır
          //context.read<CabinStatusNotifier>().startOperation(assignment, openCubicLid: shouldOpenLid);
        },
      )..getRefundables(),
      child: Consumer<MedicineRefundNotifier>(
        builder: (context, notifier, _) {
          return CabinProcessWrapper(
            onDrawerReady: (context, activeDrawer) async {
              final currentItem = notifier.selectedItem;
              if (currentItem == null) return false;

              final bool? result = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => ChangeNotifierProvider.value(value: notifier, child: RefundConfirmationView()),
              );

              if (result == true) {
                notifier.completeRefund(
                  onFailed: (message) {
                    if (context.mounted) MessageUtils.showErrorSnackbar(context, message);
                  },
                  onSuccess: (message) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      MessageUtils.showSuccessSnackbar(context, message);
                    }
                  },
                );
              }

              return result ?? false;
            },
            child: CustomDialog(
              title: 'İade',
              maxHeight: context.height * 0.8,
              width: context.width * 0.5,
              actions: [
                if (notifier.selectedItem != null)
                  TextButton(onPressed: () => _showRefundInputView(context, notifier), child: Text('İade Et')),
              ],
              child: _buildChild(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChild() {
    return Consumer<MedicineRefundNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (notifier.isEmpty) {
          return Center(child: CommonEmptyStates.noData());
        }

        return ListView.builder(
          itemCount: notifier.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = notifier.items.elementAt(index);
            final isSelected = notifier.selectedItem?.id == item.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: CabinOperationCard(item: item, isSelected: isSelected, onTap: () => notifier.selectItem(item)),
            );
          },
        );
      },
    );
  }
}

void _showRefundInputView(BuildContext context, MedicineRefundNotifier notifier) async {
  await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ChangeNotifierProvider.value(value: notifier, child: ReturnInputView()),
  );
}
