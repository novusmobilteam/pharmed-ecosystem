// LoginModal
// [SWREQ-UI-AUTH-003]
// Giriş formu. Dışarıya tıklayarak kapatılamaz.

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class LoginModal extends StatefulWidget {
  const LoginModal({super.key, required this.onLogin, required this.onCancel});

  /// username, password → hata mesajı veya null (başarılı)
  final Future<String?> Function(String username, String password) onLogin;
  final VoidCallback onCancel;

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _errorMessage;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_userCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _errorMessage = "Kullanıcı adı ve şifre gereklidir.");
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // onLogin artık Future<String?> dönüyor
      final error = await widget.onLogin(_userCtrl.text, _passCtrl.text);

      if (!mounted) return;

      if (error == null) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _loading = false;
          _errorMessage = error;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = "Beklenmedik bir hata oluştu.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
      backgroundColor: MedColors.surface,
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [MedColors.surface2, MedColors.surface],
                ),
                border: Border(bottom: BorderSide(color: MedColors.border2)),
                borderRadius: const BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [MedColors.blue, Color(0xFF5BA3EC)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sisteme Giriş',
                        style: TextStyle(
                          fontFamily: MedFonts.title,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MedColors.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  _FormField(
                    label: 'Kullanıcı Adı',
                    controller: _userCtrl,
                    placeholder: 'kullanici.adi',
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    label: 'Şifre',
                    controller: _passCtrl,
                    placeholder: '••••••••',
                    obscure: true,
                    onSubmit: _submit,
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: MedColors.redLight,
                        border: Border.all(color: const Color(0xFFF2B3AE)),
                        borderRadius: MedRadius.smAll,
                      ),
                      child: Text(_errorMessage!, style: MedTextStyles.bodySm(color: MedColors.red)),
                    ),
                  ],
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _loading ? null : _submit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: _loading ? MedColors.blue.withOpacity(0.6) : MedColors.blue,
                        borderRadius: MedRadius.mdAll,
                        boxShadow: const [BoxShadow(color: Color(0x4D1A6BD8), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      alignment: Alignment.center,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.login_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 7),
                                Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    fontFamily: MedFonts.sans,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: MedColors.border),
                        borderRadius: MedRadius.mdAll,
                      ),
                      alignment: Alignment.center,
                      child: Text('İptal', style: MedTextStyles.bodySm(color: MedColors.text3)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.obscure = false,
    this.onSubmit,
  });

  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool obscure;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: MedFonts.sans,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: MedColors.text2,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscure,
          onSubmitted: (_) => onSubmit?.call(),
          style: MedTextStyles.bodyMd(),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: MedTextStyles.bodyMd(color: MedColors.text4),
            filled: true,
            fillColor: MedColors.surface2,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: MedColors.border, width: 1.5),
              borderRadius: MedRadius.smAll,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: MedColors.blue, width: 1.5),
              borderRadius: MedRadius.smAll,
            ),
          ),
        ),
      ],
    );
  }
}
