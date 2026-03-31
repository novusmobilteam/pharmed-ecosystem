import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../../../../settings/presentation/notifier/settings_notifier.dart';
import '../notifier/cabin_inventory_notifier.dart';
import 'cubic_loading_view.dart';
import 'drawer_loading_view.dart';

Future<bool> showCabinInventoryView(
  BuildContext context, {
  required CabinAssignment initial,
  required CabinOperationCallback onSave,
  required double quantity,
  // Dolum yapılması planlanan miktar. İlaç Dolum Listesi tarafında kullanılıyor
  double? plannedQuantity,
  CabinInventoryType inventoryType = CabinInventoryType.refill,
}) async {
  final settings = context.read<SettingsNotifier>();
  final bool isPerCellMiad = settings.isPerCellMiadEnabled;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ChangeNotifierProvider(
      create: (BuildContext context) => CabinInventoryNotifier(
        initial: initial,
        onSave: onSave,
        inventoryType: inventoryType,
        isPerCellMiadEnabled: isPerCellMiad,
      ),
      child: CabinInventoryView(type: inventoryType, quantity: quantity, plannedQuantity: plannedQuantity),
    ),
  );

  return result ?? false;
}

class CabinInventoryView extends StatefulWidget {
  const CabinInventoryView({super.key, required this.type, required this.quantity, this.plannedQuantity});

  final CabinInventoryType type;
  final double quantity;
  final double? plannedQuantity;

  @override
  State<CabinInventoryView> createState() => _CabinInventoryViewState();
}

class _CabinInventoryViewState extends State<CabinInventoryView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CabinInventoryNotifier>(
      builder: (context, notifier, _) {
        double heightFactor = notifier.isKubik ? 0.8 : 1;

        return RegistrationDialog(
          title: widget.type.title,
          width: context.width * 0.4,
          maxHeight: heightFactor * context.height,
          isLoading: notifier.isSubmitting,
          onClose: () => context.pop(false),
          onSave: () {
            notifier.submit(
              onFailed: (message) => MessageUtils.showErrorSnackbar(context, message),
              onSuccess: (message) {
                MessageUtils.showSuccessSnackbar(context, message);
                context.pop(true);
              },
            );
          },
          child: SingleChildScrollView(child: _buildContent(notifier)),
        );
      },
    );
  }

  Widget _buildContent(CabinInventoryNotifier notifier) {
    print('planned Quantiy inventory: ${widget.plannedQuantity}');
    if (notifier.isKubik) {
      return CubicLoadingView(
        data: notifier.initial,
        quantity: widget.quantity,
        type: widget.type,
        onMiadDateChanged: notifier.changeMiadDate,
        onCountQuantityChanged: notifier.changeCubicCountQuantity,
        onFillingQuantityChanged: notifier.changeCubicFillingQuantity,
        countQuantity: notifier.cubicCountQuantity,
        fillingQuantity: notifier.cubicFillingQuantity,
        isExpired: notifier.isCubicExpired,
        plannedQuantity: widget.plannedQuantity,
      );
    } else {
      return DrawerLoadingView(
        data: notifier.initial,
        quantity: widget.quantity,
        plannedQuantity: widget.plannedQuantity,
        type: widget.type,
        onMiadDateChanged: notifier.changeMiadDate,
        countQuantities: notifier.drawerCountQuantities,
        fillingQuantities: notifier.drawerFillingQuantities,
        onCountQuantityChanged: (quantity, index) => notifier.changeDrawerCountQuantity(index: index, value: quantity),
        onFillingQuantityChanged: (quantity, index) =>
            notifier.changeDrawerFillingQuantity(index: index, value: quantity),
        isPerCellMiadEnabled: notifier.isPerCellMiadEnabled,
        onCellMiadChanged: (date, index) => notifier.changeDrawerMiadDate(index: index, date: date),
        cellMiadDates: notifier.drawerMiadDates,
        expiredCellIndexes: notifier.expiredCellIndexes,
      );
    }
  }
}
