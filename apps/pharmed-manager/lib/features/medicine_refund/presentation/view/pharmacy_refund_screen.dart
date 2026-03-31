import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/completed_pharmacy_refund_notifier.dart';
import '../notifier/pharmacy_refund_notifier.dart';

part 'completed_pharmacy_refunds_view.dart';

class PharmacyRefundScreen extends StatefulWidget {
  const PharmacyRefundScreen({super.key});

  @override
  State<PharmacyRefundScreen> createState() => _PharmacyRefundScreenState();
}

class _PharmacyRefundScreenState extends State<PharmacyRefundScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PharmacyRefundNotifier(
        getPharmacyRefundsUseCase: context.read(),
        completePharmacyRefundUseCase: context.read(),
        deletePharmacyRefundUseCase: context.read(),
      )..getRefunds(),
      child: Consumer<PharmacyRefundNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: 'Eczane İade Alma',
              showAddButton: false,
              isLoading: notifier.isLoading(notifier.completeOp),
              actions: [
                IconButton(
                  onPressed: () => showCompletedRefundsView(context),
                  tooltip: 'Tamamlanmış İadeler',
                  icon: Icon(PhosphorIcons.clockCounterClockwise()),
                ),
              ],
              child: _RefundTableView(notifier: notifier),
            ),
          );
        },
      ),
    );
  }
}

class _RefundTableView extends StatelessWidget {
  const _RefundTableView({required this.notifier});

  final PharmacyRefundNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<Refund>(
      data: notifier.categoryFilteredItems,
      isLoading: notifier.isFetching,
      categories: notifier.tableCategories,
      selectedCategoryId: notifier.selectedCategoryId,
      onCategoryChanged: notifier.selectCategory,
      enableSearch: true,
      onSearchChanged: notifier.search,
      enableExcel: true,
      actions: [
        TableActionItem(
          icon: PhosphorIcons.keyReturn(),
          tooltip: 'İade Al',
          color: context.colorScheme.primary,
          onPressed: (refund) => notifier.completeRefund(
            refund,
            onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
            onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
          ),
        ),
        TableActionItem.delete(onPressed: (refund) => showDeleteDescriptionView(context, refund)),
      ],
      emptyWidget: notifier.hasNoSearchResults ? CommonEmptyStates.searchNotFound() : CommonEmptyStates.noData(),
    );
  }
}

void showCompletedRefundsView(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) =>
          CompletedPharmacyRefundNotifier(getCompletedPharmacyRefundsUseCase: context.read())..getCompletedRefunds(),
      child: const CompletedRefundsView(),
    ),
  );
}

void showDeleteDescriptionView(BuildContext context, Refund data) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<PharmacyRefundNotifier>(),
      child: DeleteDescriptionView(refund: data),
    ),
  );
}

class DeleteDescriptionView extends StatelessWidget {
  const DeleteDescriptionView({super.key, required this.refund});

  final Refund refund;

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmacyRefundNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: 'Açıklama',
          maxHeight: 350,
          saveButtonText: 'Sil',
          onSave: () {
            MessageUtils.showConfirmDeleteDialog(
              context: context,
              onConfirm: () {
                notifier.deleteRefund(
                  refund,
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) {
                    MessageUtils.showSuccessSnackbar(context, msg);
                    context.pop();
                  },
                );
              },
            );
          },
          child: Column(
            children: [
              TextInputField(
                maxLines: 3,
                label: 'Silme nedeninizi açıklayınız',
                onChanged: (value) => notifier.description = value ?? '',
              ),
            ],
          ),
        );
      },
    );
  }
}
