import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';

import '../../domain/entity/kit.dart';
import '../notifier/kit_form_notifier.dart';

Future<bool> showKitFormDialog(BuildContext context, {Kit? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => KitFormNotifier(
        kit: initial,
        createKitUseCase: context.read(),
        updateKitUseCase: context.read(),
      ),
      child: KitFormDialog(),
    ),
  );

  return result ?? false;
}

class KitFormDialog extends StatefulWidget {
  const KitFormDialog({super.key});

  @override
  State<KitFormDialog> createState() => _KitFormDialogState();
}

class _KitFormDialogState extends State<KitFormDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<KitFormNotifier>(
      builder: (context, notifier, _) {
        final String title = notifier.isCreate ? 'Yeni Kit' : 'Kit Düzenle';

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
              children: const [
                _NameField(),
                _StatusField(),
              ],
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
    return Consumer<KitFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Kit Adı',
          initialValue: notifier.kit.name,
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
    return Consumer<KitFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: notifier.kit.status,
          options: Status.values,
          labelBuilder: (status) => status?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: notifier.updateStatus,
        );
      },
    );
  }
}
