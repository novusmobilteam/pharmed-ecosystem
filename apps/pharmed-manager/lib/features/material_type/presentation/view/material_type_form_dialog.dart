import 'package:flutter/material.dart' hide MaterialType;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';

import '../notifier/material_type_form_notifier.dart';

Future<bool> showMaterialTypeFormDialog(BuildContext context, {MaterialType? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => MaterialTypeFormNotifier(
        materialType: initial,
        createMaterialTypeUseCase: context.read(),
        updateMaterialTypeUseCase: context.read(),
      ),
      child: const MaterialTypeFormDialog(),
    ),
  );

  return result ?? false;
}

class MaterialTypeFormDialog extends StatefulWidget {
  const MaterialTypeFormDialog({super.key});

  @override
  State<MaterialTypeFormDialog> createState() => _MaterialTypeFormDialogState();
}

class _MaterialTypeFormDialogState extends State<MaterialTypeFormDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialTypeFormNotifier>(
      builder: (context, notifier, _) {
        final String title = notifier.isCreate ? 'Yeni Malzeme Tipi' : 'Malzeme Tipi Düzenle';

        return RegistrationDialog(
          title: title,
          width: 600,
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
          onClose: () => context.pop(false),
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
    return Consumer<MaterialTypeFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Malzeme Tipi Adı',
          initialValue: notifier.materialType.name,
          validator: (v) => Validators.cannotBlankValidator(v),
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
    return Consumer<MaterialTypeFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: notifier.materialType.status,
          options: Status.values,
          labelBuilder: (status) => status?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: notifier.updateStatus,
        );
      },
    );
  }
}
