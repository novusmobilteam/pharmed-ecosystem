import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/change_password_notifier.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const ChangePasswordView(),
    );
  }

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChangePasswordNotifier(changePasswordUseCase: context.read()),
      child: Consumer<ChangePasswordNotifier>(
        builder: (context, notifier, child) {
          return CustomDialog(
            maxHeight: 450,
            width: 400,
            title: context.l10n.changePassword_dialogTitle,
            isLoading: notifier.isSubmitting,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPasswordField(
                    label: context.l10n.changePassword_currentPasswordLabel,
                    obscureText: notifier.obscureCurrent,
                    onToggleVisibility: notifier.toggleCurrent,
                    onChanged: (value) => notifier.changeCurrent(value),
                    validator: (val) => Validators.cannotBlankValidator(val),
                  ),
                  SizedBox(height: 20),
                  _buildPasswordField(
                    label: context.l10n.changePassword_newPasswordLabel,
                    obscureText: notifier.obscureNew,
                    onToggleVisibility: notifier.toggleNew,
                    onChanged: (value) => notifier.changeNew(value),
                    validator: (val) => Validators.cannotBlankValidator(val),
                  ),
                  SizedBox(height: 20),
                  _buildPasswordField(
                    label: context.l10n.changePassword_confirmPasswordLabel,
                    obscureText: notifier.obscureNew,
                    onToggleVisibility: notifier.toggleNew,
                    onChanged: (value) => notifier.changeNew(value),
                    validator: (value) => Validators.confirmPasswordValidator(value, notifier.newPassword),
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: MedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await notifier.changePassword();

                          if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
                            MessageUtils.showSuccessSnackbar(context, notifier.statusMessage);
                            Navigator.pop(context);
                          } else if (context.mounted && notifier.isFailed(notifier.submitOp)) {
                            MessageUtils.showErrorDialog(context, notifier.statusMessage);
                          }
                        }
                      },
                      label: context.l10n.changePassword_submitButton,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required ValueChanged<String> onChanged,
    String? Function(String? val)? validator,
  }) {
    return TextFormField(
      obscureText: obscureText,
      validator: (value) => validator != null ? validator.call(value) : Validators.cannotBlankValidator(value),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
