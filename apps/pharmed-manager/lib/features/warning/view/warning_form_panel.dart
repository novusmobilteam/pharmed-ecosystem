import 'package:flutter/material.dart';
import '../../../../widgets/side_panel.dart';
import 'package:provider/provider.dart';
import '../../../../core/core.dart';

import '../notifier/warning_form_notifier.dart';
import '../notifier/warning_notifier.dart';

class WarningFormPanel extends StatelessWidget {
  const WarningFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final warningNotifier = context.watch<WarningNotifier>();
    final formKey = GlobalKey<FormState>();
    final isNew = warningNotifier.selectedWarning == null;
    final selectedWarning = warningNotifier.selectedWarning;

    return ChangeNotifierProvider(
      key: ValueKey(selectedWarning?.id ?? 'create'),
      create: (BuildContext context) => WarningFormNotifier(
        createWarningUseCase: context.read(),
        updateWarningUseCase: context.read(),
        warning: selectedWarning,
      ),
      child: Consumer<WarningFormNotifier>(
        builder: (context, formNotifier, _) {
          return SidePanel(
            title: isNew ? context.l10n.warningFormAddTitle : context.l10n.warningFormEditTitle,
            subtitle: isNew ? context.l10n.warningFormAddSubtitle : context.l10n.warningFormEditSubtitle,
            isLoading: formNotifier.isSubmitting,
            onClose: warningNotifier.closePanel,
            onSave: () async {
              if (formKey.currentState!.validate()) {
                await formNotifier.submit(successMessage: context.l10n.common_operationSuccessMessage);

                if (context.mounted && formNotifier.isSuccess(formNotifier.submitOp)) {
                  MessageUtils.showSuccessSnackbar(context, formNotifier.statusMessage);
                  warningNotifier.closePanel();
                  warningNotifier.getWarnings();
                } else if (context.mounted && formNotifier.isFailed(formNotifier.submitOp)) {
                  MessageUtils.showErrorDialog(context, formNotifier.statusMessage);
                }
              }
            },
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppDimensions.registrationDialogSpacing,
                children: const [_SubjectField(), _TextField(), _StatusField()],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SubjectField extends StatelessWidget {
  const _SubjectField();

  @override
  Widget build(BuildContext context) {
    return Consumer<WarningFormNotifier>(
      builder: (context, notifier, _) {
        return MedDropdownInputField<WarningSubject>(
          label: context.l10n.warningFormSubjectLabel,
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
        return MedTextInputField(
          label: context.l10n.warningFormTextLabel,
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
        return MedDropdownInputField<Status>(
          label: context.l10n.common_statusLabel,
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
