import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/dosage_form_notifier.dart';
import 'dosage_form_registration_dialog.dart';

Future<DosageForm?> showDosageFormView(BuildContext context) async {
  return await showDialog<DosageForm?>(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) =>
          DosageFormNotifier(getDosageFormsUseCase: context.read(), deleteDosageFormUseCase: context.read())
            ..getDosageForms(forceRefresh: true),
      child: Consumer<DosageFormNotifier>(
        builder: (context, vm, Widget? child) => CustomDialog(
          title: context.l10n.dosageForm_listDialogTitle,
          showSearch: true,
          showAdd: true,
          onSearchChanged: (query) => vm.search(query),
          onAddPressed: () => _onEdit(context),
          onClose: () => Navigator.of(context).pop(),
          child: DosageFormView(),
        ),
      ),
    ),
  );
}

class DosageFormView extends StatefulWidget {
  const DosageFormView({super.key});

  @override
  State<DosageFormView> createState() => _DosageFormViewState();
}

class _DosageFormViewState extends State<DosageFormView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DosageFormNotifier>(
      builder: (context, notifier, _) {
        return _buildContent(context, notifier);
      },
    );
  }

  Widget _buildContent(BuildContext context, DosageFormNotifier notifier) {
    if (notifier.isFetching && notifier.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.hasNoSearchResults) {
      return EmptyStateWidget();
    }

    if (notifier.allItems.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.science_outlined,
        variant: EmptyStateVariant.custom,
        title: context.l10n.dosageForm_emptyTitle,
        description: context.l10n.dosageForm_emptyDescription,
      );
    }

    return ListView.builder(
      itemCount: notifier.filteredItems.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final dosageForm = notifier.filteredItems[index];
        return MedEditableListCard(
          title: dosageForm.title,
          subtitle: dosageForm.subtitle,
          onEdit: () => _onEdit(context, initial: dosageForm),
          onDelete: () => _onDelete(context, dosageForm),
          onTap: () => Navigator.of(context).pop(dosageForm),
        );
      },
    );
  }
}

Future<void> _onEdit(BuildContext context, {DosageForm? initial}) async {
  final result = await showDosageFormRegistrationDialog(context, initial: initial);
  if (result == true && context.mounted) {
    context.read<DosageFormNotifier>().getDosageForms(forceRefresh: true);
  }
}

void _onDelete(BuildContext context, DosageForm item) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () => context.read<DosageFormNotifier>().deleteDosageForm(item.id!),
  );
}
