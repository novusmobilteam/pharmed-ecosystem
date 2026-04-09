import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../notifier/unit_form_notifier.dart';

Future<bool> showUnitFormDialog(BuildContext context, {Unit? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) =>
          UnitFormNotifier(unit: initial, createUnitUseCase: context.read(), updateUnitUseCase: context.read()),
      child: const UnitFormDialog(),
    ),
  );

  return result ?? false;
}

class UnitFormDialog extends StatefulWidget {
  const UnitFormDialog({super.key});

  @override
  State<UnitFormDialog> createState() => _UnitFormDialogState();
}

class _UnitFormDialogState extends State<UnitFormDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<UnitFormNotifier>(
      builder: (context, notifier, _) {
        final String title = notifier.isCreate ? 'Yeni Birim Oluştur' : 'Birim Düzenle';

        return RegistrationDialog(
          title: title,
          width: 400,
          maxHeight: 400,
          isLoading: notifier.isLoading(notifier.submitOp),
          onSave: () async {
            if (formKey.currentState!.validate()) {
              await notifier.submit(
                onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                onSuccess: (msg) {
                  MessageUtils.showSuccessSnackbar(context, msg);
                  context.pop(true);
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
    return Consumer<UnitFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Adı',
          autoFocus: notifier.isCreate,
          initialValue: notifier.unit.name,
          validator: Validators.cannotBlankValidator,
          onChanged: notifier.updateName,
        );
      },
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UnitFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          options: Status.values,
          labelBuilder: (status) => status?.label,
          initialValue: notifier.unit.status,
          validator: (value) => Validators.cannotBlankValidator(value?.name),
          onChanged: notifier.updateStatus,
        );
      },
    );
  }
}
