import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/form/form_inputs/numpad_input_field.dart';
import '../../../medicine_management/domain/entity/cabin_operation_item.dart';
import '../../../medicine_management/presentation/view/witness_login_view.dart';
import '../../../medicine_management/presentation/widgets/cabin_operation_card/cabin_operation_card.dart';
import '../notifier/disposal_notifier.dart';
part 'disposal_input_view.dart';

class DisposalView extends StatefulWidget {
  const DisposalView({super.key, this.hospitalization});

  final Hospitalization? hospitalization;

  @override
  State<DisposalView> createState() => _DisposalViewState();
}

class _DisposalViewState extends State<DisposalView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DisposalNotifier(
        hospitalization: widget.hospitalization,
        getDisposablesUseCase: context.read(),
        getCurrentStationUseCase: context.read(),
        disposeMedicineUseCase: context.read(),
        onVerificationCompleted: (notifier) async {
          await showDialog(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(value: notifier, child: const DisposalInputView()),
          );
        },
      )..initialize(),
      child: Consumer<DisposalNotifier>(
        builder: (context, notifier, _) {
          return CustomDialog(
            title: 'Fire/İmha',
            maxHeight: context.height * 0.8,
            width: context.width * 0.5,
            actions: [
              if (notifier.selectedItem != null)
                TextButton(
                  onPressed: () =>
                      notifier.startOperation(onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg)),
                  child: const Text('Fire/İmha Et'),
                ),
            ],
            child: _buildChild(),
          );
        },
      ),
    );
  }

  Widget _buildChild() {
    return Consumer<DisposalNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (notifier.isEmpty) {
          return Center(child: CommonEmptyStates.noData());
        }

        return ListView.builder(
          itemCount: notifier.items.length,
          itemBuilder: (context, index) {
            final item = notifier.items.elementAt(index);
            final bool isSelected = notifier.selectedItem?.id == item.id;
            final bool isCompleted = notifier.completedItemIds.contains(item.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: CabinOperationCard(
                key: ObjectKey(item),
                item: item,
                isSelected: isSelected,
                isCompleted: isCompleted,
                currentStation: notifier.currentStation,
                onTap: () => notifier.selectItem(item),
                onWitnessLoggedIn: (user) => notifier.addWitness(item, user),
                onWitnessTap: () => _openWitnessDialog(context, notifier, item),
              ),
            );
          },
        );
      },
    );
  }

  void _openWitnessDialog(BuildContext context, DisposalNotifier notifier, CabinOperationItem item) {
    // Güncel referansı notifier'dan al
    final currentItem = notifier.items.firstWhere((i) => i.id == item.id, orElse: () => item);

    showDialog<bool>(
      context: context,
      builder: (_) =>
          WitnessLoginView(item: currentItem, onWitnessLoggedIn: (user) => notifier.addWitness(currentItem, user)),
    );
  }
}
