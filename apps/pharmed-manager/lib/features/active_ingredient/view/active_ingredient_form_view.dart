import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/active_ingredient_form_notifier.dart';

Future<bool> showActiveIngredientFormDialog(BuildContext context, {ActiveIngredient? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => ActiveIngredientFormNotifier(
        activeIngredient: initial,
        createActiveIngredientUseCase: context.read(),
        updateActiveIngredientUseCase: context.read(),
      ),
      child: const ActiveIngredientFormDialog(),
    ),
  );

  return result ?? false;
}

class ActiveIngredientFormDialog extends StatefulWidget {
  const ActiveIngredientFormDialog({super.key});

  @override
  State<ActiveIngredientFormDialog> createState() => _ActiveIngredientFormDialogState();
}

class _ActiveIngredientFormDialogState extends State<ActiveIngredientFormDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveIngredientFormNotifier>(
      builder: (context, notifier, _) {
        final String title = notifier.isCreate ? 'Etken Madde Ekle' : 'Etken Madde Düzenle';
        return RegistrationDialog(
          title: title,
          maxHeight: 400,
          width: 400,
          isLoading: notifier.isSubmitting,
          onSave: () async {
            if (formKey.currentState!.validate()) {
              await notifier.submit(
                onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                onSuccess: (msg) {
                  context.pop(true);
                  MessageUtils.showSuccessSnackbar(context, msg);
                },
              );
            }
          },
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppDimensions.registrationDialogSpacing,
              children: const [_NameField(), _StatusField()],
            ),
          ),
        );
      },
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveIngredientFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Adı',
          autoFocus: vm.isCreate,
          initialValue: vm.activeIngredient.name,
          validator: (v) => Validators.cannotBlankValidator(v),
          onChanged: vm.updateName,
        );
      },
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveIngredientFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: vm.activeIngredient.status,
          options: Status.values,
          labelBuilder: (value) => value?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: vm.updateStatus,
        );
      },
    );
  }
}
