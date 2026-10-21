// [SWREQ-CLI-AUTH-PWD-001] [IEC 62304 §5.5]
// Ayarlar › Şifre Değiştir bölümü. Ayarlar yalnızca oturum açıkken
// erişilebilir olduğu için bölüm oturumdaki kullanıcıya uygulanır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/change_password_notifier.dart';

class ChangePasswordSettingsView extends ConsumerStatefulWidget {
  const ChangePasswordSettingsView({super.key});

  @override
  ConsumerState<ChangePasswordSettingsView> createState() => _ChangePasswordSettingsViewState();
}

class _ChangePasswordSettingsViewState extends ConsumerState<ChangePasswordSettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onEdited(String? _) => ref.read(changePasswordNotifierProvider.notifier).clearResult();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref
        .read(changePasswordNotifierProvider.notifier)
        .submit(currentPassword: _currentCtrl.text, newPassword: _newCtrl.text);

    if (success && mounted) {
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
      _formKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordNotifierProvider);
    final l10n = context.l10n;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.mdAll),
                child: Icon(PhosphorIcons.lockKey(), color: MedColors.blue, size: 26),
              ),
              const SizedBox(width: MedSpacing.lg),
              Expanded(
                child: Text(l10n.changePassword_dialogTitle, style: MedTextStyles.titleMd(color: MedColors.text)),
              ),
            ],
          ),
          const SizedBox(height: MedSpacing.lg),
          Text(
            l10n.changePassword_settingsDescription,
            style: MedTextStyles.bodyMd(color: MedColors.text2).copyWith(height: 1.5),
          ),
          const SizedBox(height: MedSpacing.xl),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MedTextInputField(
                  controller: _currentCtrl,
                  label: l10n.changePassword_currentPasswordLabel,
                  obscureText: _obscureCurrent,
                  enabled: !state.isSubmitting,
                  onChanged: _onEdited,
                  validator: Validators.cannotBlankValidator,
                  prefixIcon: Icon(PhosphorIcons.lock(), size: 18),
                  suffixIcon: _VisibilityToggle(
                    obscured: _obscureCurrent,
                    onTap: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                const SizedBox(height: MedSpacing.xl),
                MedTextInputField(
                  controller: _newCtrl,
                  label: l10n.changePassword_newPasswordLabel,
                  obscureText: _obscureNew,
                  enabled: !state.isSubmitting,
                  onChanged: _onEdited,
                  validator: Validators.passwordValidator,
                  prefixIcon: Icon(PhosphorIcons.lockKey(), size: 18),
                  suffixIcon: _VisibilityToggle(
                    obscured: _obscureNew,
                    onTap: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                const SizedBox(height: MedSpacing.lg),
                MedTextInputField(
                  controller: _confirmCtrl,
                  label: l10n.changePassword_confirmPasswordLabel,
                  obscureText: _obscureNew,
                  enabled: !state.isSubmitting,
                  onChanged: _onEdited,
                  validator: (value) => Validators.confirmPasswordValidator(value, _newCtrl.text),
                  onFieldSubmitted: (_) => _submit(),
                  prefixIcon: Icon(PhosphorIcons.lockKey(), size: 18),
                ),
                const SizedBox(height: MedSpacing.xl),

                if (state.status == ChangePasswordStatus.success) ...[
                  _ResultNotice(
                    icon: PhosphorIcons.checkCircle(),
                    text: l10n.changePassword_successMessage,
                    isError: false,
                  ),
                  const SizedBox(height: MedSpacing.lg),
                ] else if (state.status == ChangePasswordStatus.failure) ...[
                  _ResultNotice(
                    icon: PhosphorIcons.warningCircle(),
                    text: state.errorMessage ?? l10n.changePassword_errorFallback,
                    isError: true,
                  ),
                  const SizedBox(height: MedSpacing.lg),
                ],

                MedButton(
                  label: l10n.changePassword_submitButton,
                  prefixIcon: Icon(PhosphorIcons.check()),
                  isLoading: state.isSubmitting,
                  onPressed: state.isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscured, required this.onTap});

  final bool obscured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // Dokunmatik ekranda rahat basılabilsin.
      constraints: const BoxConstraints(minWidth: MedSpacing.touchTarget, minHeight: MedSpacing.touchTarget),
      icon: Icon(obscured ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash(), size: 20, color: MedColors.text3),
      onPressed: onTap,
    );
  }
}

class _ResultNotice extends StatelessWidget {
  const _ResultNotice({required this.icon, required this.text, required this.isError});

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, border) = isError
        ? (MedColors.red, MedColors.redLight, MedColors.red.withAlpha(60))
        : (MedColors.green, MedColors.greenLight, MedColors.green.withAlpha(60));

    return Container(
      width: double.infinity,
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Text(
              text,
              style: MedTextStyles.bodySm(color: fg, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
