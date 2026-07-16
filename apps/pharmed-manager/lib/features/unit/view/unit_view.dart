import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/unit_notifier.dart';
import 'unit_form_dialog.dart';

Future<Unit?> showUnitView(BuildContext context) async {
  return await showDialog<Unit?>(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) => UnitNotifier(getUnitsUseCase: context.read(), deleteUnitUseCase: context.read())..getUnits(),
      child: Consumer<UnitNotifier>(
        builder: (context, notifier, Widget? child) => CustomDialog(
          title: context.l10n.unitDialogTitle,
          showSearch: true,
          showAdd: true,
          onSearchChanged: (query) => notifier.search(query),
          onAddPressed: () => _onEdit(context),
          onClose: () => Navigator.of(context).pop(),
          child: UnitView(),
        ),
      ),
    ),
  );
}

class UnitView extends StatefulWidget {
  const UnitView({super.key});

  @override
  State<UnitView> createState() => _UnitViewState();
}

class _UnitViewState extends State<UnitView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UnitNotifier>(
      builder: (context, notifier, _) {
        return _buildContent(context, notifier);
      },
    );
  }

  Widget _buildContent(BuildContext context, UnitNotifier notifier) {
    if (notifier.isFetching && notifier.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.hasNoSearchResults) {
      return EmptyStateWidget(variant: EmptyStateVariant.noResults);
    }

    if (notifier.allItems.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.square_foot_outlined,
        variant: EmptyStateVariant.custom,
        title: context.l10n.unitListEmptyTitle,
        description: context.l10n.common_addItemHint('birim'),
      );
    }

    return ListView.builder(
      itemCount: notifier.filteredItems.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final unit = notifier.filteredItems[index];
        return MedEditableListCard(
          title: unit.title,
          subtitle: unit.subtitle,
          onEdit: () => _onEdit(context, initial: unit),
          onDelete: () => _onDelete(context, unit),
          onTap: () => Navigator.of(context).pop(unit),
        );
      },
    );
  }
}

Future<void> _onEdit(BuildContext context, {Unit? initial}) async {
  final result = await showUnitFormDialog(context, initial: initial);
  if (result == true && context.mounted) {
    context.read<UnitNotifier>().getUnits();
  }
}

void _onDelete(BuildContext context, Unit item) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () => context.read<UnitNotifier>().deleteUnit(
      item,
      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
      onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
    ),
  );
}
