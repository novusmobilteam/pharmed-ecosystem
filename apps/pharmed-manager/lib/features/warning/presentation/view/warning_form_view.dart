import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../core/core.dart';

import '../../domain/entity/warning.dart';
import '../notifier/warning_form_notifier.dart';

Future<bool> showWarningFormDialog(BuildContext context, {Warning? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => WarningFormNotifier(
        warning: initial,
        createWarningUseCase: context.read(),
        updateWarningUseCase: context.read(),
      ),
      child: const WarningFormView(),
    ),
  );

  return result ?? false;
}

class WarningFormView extends StatefulWidget {
  const WarningFormView({super.key});

  @override
  State<WarningFormView> createState() => _WarningFormViewState();
}

class _WarningFormViewState extends State<WarningFormView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<WarningFormNotifier>(
      builder: (context, notifier, _) {
        final String title = notifier.isCreate ? 'Uyarı Ekle' : 'Uyarı Düzenle';

        return RegistrationDialog(
          title: title,
          isLoading: notifier.isLoading(notifier.submitOp),
          onSave: () async {
            await notifier.submit(
              onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
              onSuccess: (msg) {
                MessageUtils.showSuccessSnackbar(context, msg);
                context.pop(true);
              },
            );
          },
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppDimensions.registrationDialogSpacing,
              children: const [
                _SubjectField(),
                _TextField(),
                _StatusField(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubjectField extends StatelessWidget {
  const _SubjectField();

  @override
  Widget build(BuildContext context) {
    return Consumer<WarningFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<WarningSubject>(
          label: 'Uyarı Konusu',
          options: WarningSubject.values,
          initialValue: notifier.warning.subject,
          labelBuilder: (s) => s?.label,
          validator: (s) => Validators.cannotBlankValidator(s?.label),
          onChanged: notifier.updateSubject,
        );
      },
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField();

  @override
  Widget build(BuildContext context) {
    return Consumer<WarningFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Uyarı Metni',
          autoFocus: notifier.isCreate,
          initialValue: notifier.warning.text,
          validator: Validators.cannotBlankValidator,
          onChanged: notifier.updateText,
        );
      },
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<WarningFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: notifier.warning.status,
          options: Status.values,
          labelBuilder: (s) => s?.label,
          validator: (s) => Validators.cannotBlankValidator(s?.label),
          onChanged: notifier.updateStatus,
        );
      },
    );
  }
}
