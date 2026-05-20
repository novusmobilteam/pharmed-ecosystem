import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginModal extends StatefulWidget {
  const LoginModal({super.key, required this.onLogin, this.isLoading = false});

  final Future<void> Function(String username, String password, ValueChanged<String> onError) onLogin;

  final bool isLoading;

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.onLogin(_userCtrl.text.trim(), _passCtrl.text, (msg) {
      if (!mounted) return;
      MessageUtils.showErrorSnackbar(context, msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
      backgroundColor: MedColors.surface,
      child: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                decoration: BoxDecoration(
                  color: MedColors.blue,
                  borderRadius: const BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIconsBold.lock, color: Colors.white, size: 30),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.auth_loginSubtitle, style: MedTextStyles.titleMd(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MedTextInputField(
                      onChanged: (_) {},
                      controller: _userCtrl,
                      label: context.l10n.auth_emailLabel,
                      validator: Validators.cannotBlankValidator,
                    ),
                    const SizedBox(height: 14),
                    MedTextInputField(
                      onChanged: (_) {},
                      controller: _passCtrl,
                      obscureText: true,
                      label: context.l10n.auth_passwordLabel,
                      validator: Validators.cannotBlankValidator,
                    ),
                    const SizedBox(height: 24),
                    MedButton(
                      label: context.l10n.auth_loginButton,
                      isLoading: widget.isLoading,
                      onPressed: widget.isLoading ? null : _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
