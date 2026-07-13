import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginModal extends StatefulWidget {
  const LoginModal({super.key, required this.onLogin, this.isLoading = false, this.onLoginWithBadge});

  final Future<void> Function(String username, String password, ValueChanged<String> onError) onLogin;
  final Future<void> Function(String cardData, ValueChanged<String> onError)? onLoginWithBadge;
  final bool isLoading;

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool loginWithUsername = true;

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

  Future<void> _submitWithBadge(String? cardData) async {
    if (widget.onLoginWithBadge != null && cardData != null) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      await widget.onLoginWithBadge!(cardData, (msg) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, msg);
      });
    }
  }

  void changeLoginMethod(int index) {
    setState(() {
      if (index == 0) {
        loginWithUsername = true;
      } else {
        loginWithUsername = false;
      }
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
              if (widget.onLoginWithBadge != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 22.0, right: 22.0),
                  child: MedSegmentedButton(
                    selectedIndex: loginWithUsername ? 0 : 1,
                    onChanged: (i) => changeLoginMethod(i),
                    labels: [context.l10n.auth_emailLabel, context.l10n.user_badgeCardLabel],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: loginWithUsername ? _loginWithUsernameView() : _loginWithBadge(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginWithUsernameView() {
    return Column(
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
        const SizedBox(height: 12),
        MedButton(
          label: context.l10n.auth_loginButton,
          isLoading: widget.isLoading,
          onPressed: widget.isLoading ? null : _submit,
        ),
      ],
    );
  }

  Widget _loginWithBadge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MedTextInputField(
          onChanged: (_) {},
          autoFocus: true,
          hint: context.l10n.user_badgeCardHint,
          validator: Validators.cannotBlankValidator,
          onFieldSubmitted: (value) => _submitWithBadge(value),
        ),
        const SizedBox(height: 12),
        MedButton(
          label: context.l10n.auth_loginButton,
          isLoading: widget.isLoading,
          onPressed: widget.isLoading ? null : _submit,
        ),
      ],
    );
  }
}
