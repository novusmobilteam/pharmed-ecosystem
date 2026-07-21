import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_core/pharmed_core.dart';

class LoginModal extends StatefulWidget {
  const LoginModal({
    super.key,
    required this.onLogin,
    this.isLoading = false,
    this.onLoginWithBadge,
    this.currentLanguage,
    this.onLanguageChanged,
  });

  final Future<void> Function(String username, String password, ValueChanged<String> onError) onLogin;
  final Future<void> Function(String cardData, ValueChanged<String> onError)? onLoginWithBadge;
  final bool isLoading;

  /// Şu an seçili dil. null gelirse dil seçici gösterilmez.
  final AppLanguage? currentLanguage;

  /// Kullanıcı dil seçtiğinde tetiklenir. null ise dil seçici gösterilmez.
  final ValueChanged<AppLanguage>? onLanguageChanged;

  bool get _showLanguageBar => currentLanguage != null && onLanguageChanged != null;

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
      await widget.onLoginWithBadge!(cardData, (msg) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, msg);
      });
    }
  }

  void _changeLoginMethod(int index) {
    setState(() => loginWithUsername = index == 0);
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
              _buildHeader(),
              if (widget._showLanguageBar)
                _LanguageBar(current: widget.currentLanguage!, onChanged: widget.onLanguageChanged!),
              if (widget.onLoginWithBadge != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 22, right: 22),
                  child: MedSegmentedButton(
                    selectedIndex: loginWithUsername ? 0 : 1,
                    onChanged: _changeLoginMethod,
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      decoration: BoxDecoration(
        color: MedColors.blue,
        borderRadius: const BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsBold.lock, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Text(context.l10n.auth_loginSubtitle, style: MedTextStyles.titleMd(color: Colors.white)),
        ],
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
          onFieldSubmitted: _submitWithBadge,
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

/// Header ile form arasında ince yatay dil seçici.
class _LanguageBar extends StatelessWidget {
  const _LanguageBar({required this.current, required this.onChanged});

  final AppLanguage current;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),

      child: MedSegmentedButton(
        selectedIndex: AppLanguage.values.indexOf(current),
        onChanged: (i) => onChanged(AppLanguage.values[i]),
        labels: AppLanguage.values.map((l) => '${l.nativeName}').toList(),
      ),
      // child: Row(
      //   children: AppLanguage.values.map((lang) {
      //     final isSelected = lang == current;
      //     return Padding(
      //       padding: const EdgeInsets.only(right: 6),
      //       child: GestureDetector(
      //         onTap: () => onChanged(lang),
      //         child: AnimatedContainer(
      //           duration: const Duration(milliseconds: 150),
      //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      //           decoration: BoxDecoration(
      //             color: isSelected ? MedColors.blueLight : Colors.transparent,
      //             border: Border.all(color: isSelected ? MedColors.blue : MedColors.border),
      //             borderRadius: MedRadius.smAll,
      //           ),
      //           child: Row(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Text(
      //                 lang.displayCode,
      //                 style: TextStyle(
      //                   fontFamily: MedFonts.mono,
      //                   fontSize: 11,
      //                   fontWeight: FontWeight.w600,
      //                   letterSpacing: 0.5,
      //                   color: isSelected ? MedColors.blue : MedColors.text3,
      //                 ),
      //               ),
      //               const SizedBox(width: 5),
      //               Text(
      //                 lang.nativeName,
      //                 style: TextStyle(
      //                   fontFamily: MedFonts.sans,
      //                   fontSize: 12,
      //                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      //                   color: isSelected ? MedColors.blue : MedColors.text2,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     );
      //   }).toList(),
      // ),
    );
  }
}
