import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/change_password_notifier.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChangePasswordNotifier(
        changePasswordUseCase: context.read(),
      ),
      child: Consumer<ChangePasswordNotifier>(
        builder: (context, notifier, child) {
          return CustomDialog(
            maxHeight: 450,
            width: 400,
            title: 'Şifre Değiştirme',
            isLoading: notifier.isSubmitting,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPasswordField(
                    label: 'Mevcut Şifre',
                    obscureText: notifier.obscureCurrent,
                    onToggleVisibility: notifier.toggleCurrent,
                    onChanged: (value) => notifier.currentPassword = value,
                  ),
                  SizedBox(height: 20),
                  _buildPasswordField(
                    label: 'Yeni Şifre',
                    obscureText: notifier.obscureNew,
                    onToggleVisibility: notifier.toggleNew,
                    onChanged: (value) => notifier.newPassword = value,
                  ),
                  SizedBox(height: 20),
                  _buildPasswordField(
                    label: 'Yeni Şifre Tekrar',
                    obscureText: notifier.obscureNew,
                    onToggleVisibility: notifier.toggleNew,
                    onChanged: (value) => notifier.newPassword = value,
                    validator: (value) => Validators.confirmPasswordValidator(value, notifier.newPassword),
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: PharmedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await notifier.changePassword();

                          if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
                            MessageUtils.showSuccessSnackbar(context, notifier.statusMessage);
                            context.pop(true);
                          } else if (context.mounted && notifier.isFailed(notifier.submitOp)) {
                            MessageUtils.showErrorDialog(context, notifier.statusMessage);
                          }
                        }
                      },
                      label: 'Şifre Değiştir',
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
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
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
