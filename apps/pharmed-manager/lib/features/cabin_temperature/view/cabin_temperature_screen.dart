import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../domain/entity/cabin_temperature_detail.dart';

import '../view_model/cabin_temperature_control_form_view_model.dart';
import '../view_model/cabin_temperature_viewmodel.dart';

part 'cabin_temperature_form_view.dart';

class CabinTemperatureScreen extends StatefulWidget {
  const CabinTemperatureScreen({super.key});

  @override
  State<CabinTemperatureScreen> createState() => _CabinTemperatureScreenState();
}

class _CabinTemperatureScreenState extends State<CabinTemperatureScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          CabinTemperatureViewModel(cabinTemperatureRepository: context.read(), l10n: context.l10n)..getStations(),
      child: Consumer<CabinTemperatureViewModel>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: MedMobileLayout(),
            tablet: MedTabletLayout(),
            desktop: MedDesktopLayout(
              title: context.l10n.cabinTemperatureScreenTitle,
              showAddButton: true,
              onAddPressed: () => _onEdit(context),
              child: _TableView(notifier: notifier),
            ),
          );
        },
      ),
    );
  }
}

class _TableView extends StatelessWidget {
  const _TableView({required this.notifier});

  final CabinTemperatureViewModel notifier;

  @override
  Widget build(BuildContext context) {
    return MedTable<CabinTemperatureDetail>(
      data: notifier.temperatureDetails,
      isLoading: notifier.isFetchingDetail || notifier.isFetchingStations,
      enableExcel: true,
      categories: notifier.tableCategories,
      selectedCategoryId: notifier.selectedCategoryId,
      onCategoryChanged: notifier.selectCategory,
      // CabinTemperatureDetail.titles context'e erişimi olmayan bir entity
      // getter'ı olduğundan, kolon başlıkları burada l10n ile override edilir.
      columnDefs: [
        TableColumnDef(title: context.l10n.cabinTemperatureColumnCabin, contentIndex: 0),
        TableColumnDef(title: context.l10n.cabinTemperatureInsideBottomLabel, contentIndex: 1),
        TableColumnDef(title: context.l10n.cabinTemperatureInsideTopLabel, contentIndex: 2),
        TableColumnDef(title: context.l10n.cabinTemperatureOutsideBottomLabel, contentIndex: 3),
        TableColumnDef(title: context.l10n.cabinTemperatureOutsideTopLabel, contentIndex: 4),
        TableColumnDef(title: context.l10n.cabinTemperatureHumidityBottomLabel, contentIndex: 5),
        TableColumnDef(title: context.l10n.cabinTemperatureHumidityTopLabel, contentIndex: 6),
      ],
      actions: [
        TableActionItem.edit(context: context, onPressed: (data) => _onEdit(context, initial: data)),
        TableActionItem.delete(context: context, onPressed: (data) => _onDelete(context, data)),
      ],
    );
  }
}

Future<void> _onEdit(BuildContext context, {CabinTemperatureDetail? initial}) async {
  final changed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => CabinTemperatureFormView(initial: initial),
  );

  if (changed == true && context.mounted) {
    context.read<CabinTemperatureViewModel>().getDetail();
  }
}

void _onDelete(BuildContext context, CabinTemperatureDetail data) {
  if (data.id == null) return;
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () {
      context.read<CabinTemperatureViewModel>().deleteTemperature(
        data,
        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
      );
    },
  );
}
