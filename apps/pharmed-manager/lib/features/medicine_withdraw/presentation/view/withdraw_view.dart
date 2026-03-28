import 'package:flutter/material.dart';
import '../../../cabin/shared/cabin_process/view/cabin_process_wrapper.dart';
import '../../../medicine_management/presentation/view/witness_login_view.dart';
import '../../domain/utils/withdraw_check_status.dart';
import '../widgets/withdraw_operation_card.dart';
import 'withdraw_count_view.dart';

import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../cabin/shared/cabin_process/notifier/cabin_status_notifier.dart';
import '../../../hospitalization/domain/entity/hospitalization.dart';

import '../notifier/withdraw_notifier.dart';

class WithdrawView extends StatefulWidget {
  /// İlaç Alım ekranı. Orderlı ve Ordersız alım için de aynı view kullanılıyor.
  const WithdrawView({super.key, this.hospitalization, required this.withdrawType});

  final Hospitalization? hospitalization;
  final WithdrawType withdrawType;

  @override
  State<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<WithdrawView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WithdrawNotifier(
        type: widget.withdrawType,
        getWithdrawItemsUseCase: context.read(),
        hospitalization: widget.hospitalization,
        checkWithdrawUseCase: context.read(),
        completeWithdrawUseCase: context.read(),
        authPersistence: context.read(),
        getCurrentStationUseCase: context.read(),
        onChecksCompleted: (notifier) async {
          if (notifier.currentAssignment == null) return;
          context.read<CabinStatusNotifier>().startOperation(
            notifier.currentAssignment!,
            requestedQuantity: notifier.currentItem?.dosePiece ?? 0,
          );
        },
      )..initialize(),
      child: Consumer<WithdrawNotifier>(
        builder: (context, notifier, _) {
          return CabinProcessWrapper(
            onDrawerReady: (wrapperContext, _) async {
              final result = await showDialog<bool?>(
                context: wrapperContext,
                barrierDismissible: true,
                builder: (dialogContext) =>
                    ChangeNotifierProvider.value(value: notifier, child: const WithdrawCountView()),
              );

              return result ?? false;
            },
            onProcessCompleted: (assignment, isSuccess) async {
              await Future.delayed(const Duration(milliseconds: 1000));

              // Önce stokları güncelle, tamamlanmadan devam etme
              if (notifier.type == WithdrawType.ordered) {
                debugPrint("🔄 getItems başlıyor...");
                await notifier.getItems(refreshAssignments: true);
                debugPrint("✅ getItems tamamlandı.");
              }

              debugPrint("➡️ startWithdraw başlıyor...");
              if (notifier.selectedItems.isNotEmpty) {
                notifier.startWithdraw(
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
                );
              }
            },
            child: CustomDialog(
              title: 'İlaç Alım',
              maxHeight: context.height * 0.8,
              width: context.width * 0.5,
              actions: [_startWithdrawButton(notifier)],
              child: _buildChild(notifier),
            ),
          );
        },
      ),
    );
  }

  Widget _startWithdrawButton(WithdrawNotifier notifier) {
    if (notifier.selectedItems.isEmpty) return SizedBox.shrink();

    final isChecking = notifier.selectedItems.any((item) => notifier.checkStatuses[item.id] is CheckLoading);

    if (isChecking) {
      return Center(child: CircularProgressIndicator.adaptive());
    }

    return TextButton(
      onPressed: () => notifier.startWithdraw(
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      ),
      child: Text('Alıma Başla'),
    );
  }

  Widget _buildChild(WithdrawNotifier notifier) {
    if (notifier.isLoading(notifier.initOp) || notifier.isFetching) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (notifier.items.isEmpty) {
      return Center(child: CommonEmptyStates.noData());
    }

    return ListView.builder(
      itemCount: notifier.items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = notifier.items.elementAt(index);
        final isSelected = notifier.selectedItems.contains(item);
        final isCompleted = notifier.completedItems.contains(item.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: WithdrawOperationCard(
            key: ObjectKey(item),
            item: item,
            isSelected: isSelected,
            isCompleted: isCompleted,
            isFailed: notifier.failedItems.contains(item.id), // YENİ
            onTap: () => notifier.selectItem(item),
            onQuantityChanged: (amount) => notifier.updateWithdrawAmount(item, amount),
            onWitnessLoggedIn: (user) => notifier.addWitness(item, user),
            checkStatus: notifier.checkStatuses[item.id] ?? const CheckIdle(),
            currentStation: notifier.currentStation,
            onWitnessTap: () {
              final currentItem = notifier.items.firstWhere((i) => i.id == item.id);
              showDialog<bool>(
                context: context,
                builder: (_) => WitnessLoginView(
                  item: currentItem,
                  onWitnessLoggedIn: (user) => notifier.addWitness(currentItem, user),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
