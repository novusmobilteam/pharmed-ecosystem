import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../domain/entity/dosage_form.dart';
import '../notifier/dosage_form_notifier.dart';
import 'dosage_form_registration_dialog.dart';

Future<DosageForm?> showDosageFormView(BuildContext context) async {
  return await showDialog<DosageForm?>(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) => DosageFormNotifier(
        getDosageFormsUseCase: context.read(),
        deleteDosageFormUseCase: context.read(),
      )..getDosageForms(forceRefresh: true),
      child: Consumer<DosageFormNotifier>(
        builder: (context, vm, Widget? child) => CustomDialog(
          title: 'Dozaj Formu',
          showSearch: true,
          showAdd: true,
          onSearchChanged: (query) => vm.search(query),
          onAddPressed: () => _onEdit(context),
          onClose: () => context.pop(),
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
        return _buildContent(notifier);
      },
    );
  }

  Widget _buildContent(DosageFormNotifier notifier) {
    if (notifier.isFetching && notifier.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.hasNoSearchResults) {
      return CommonEmptyStates.searchNotFound();
    }

    if (notifier.allItems.isEmpty) {
      return CommonEmptyStates.generic(
        icon: Icons.science_outlined,
        message: 'Henüz dozaj formu bulunmuyor',
        subMessage: 'Dozaj formu oluşturmak için "+" butonuna tıklayın',
      );
    }

    return ListView.builder(
      itemCount: notifier.filteredItems.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final dosageForm = notifier.filteredItems[index];
        return EditableListItem(
          title: dosageForm.title,
          subtitle: dosageForm.subtitle,
          onEdit: () => _onEdit(context, initial: dosageForm),
          onDelete: () => _onDelete(context, dosageForm),
          onTap: () => context.pop(dosageForm),
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
