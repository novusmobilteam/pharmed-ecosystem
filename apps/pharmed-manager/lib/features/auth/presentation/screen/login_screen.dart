// lib/features/auth/presentation/screen/login_screen.dart
//
// [SWREQ-UI-AUTH-002]
// Tam ekran giriş ekranı.
// LoginModal widget'ını merkeze alır.
// AuthNotifier üzerinden login işlemi yapar.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';
import '../notifier/auth_notifier.dart';
import '../state/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();
    final authState = context.watch<AuthNotifier>().state;

    return Scaffold(
      backgroundColor: MedColors.bg,
      body: Stack(
        children: [
          const _BackgroundPattern(),

          Center(
            child: _LoginCard(
              onLogin: (email, password) async {
                await authNotifier.login(email: email, password: password);
              },
              errorMessage: switch (authState) {
                AuthError(:final message) => message,
                _ => null,
              },
              isLoading: authState is AuthLoading,
            ),
          ),

          const Positioned(left: 24, bottom: 20, child: _VersionLabel()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Login Kartı — LoginModal stilinde standalone form
// ─────────────────────────────────────────────────────────────────

class _LoginCard extends StatefulWidget {
  const _LoginCard({required this.onLogin, required this.errorMessage, required this.isLoading});

  final Future<void> Function(String email, String password) onLogin;
  final String? errorMessage;
  final bool isLoading;

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) return;
    await widget.onLogin(_emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: BoxDecoration(color: MedColors.surface, borderRadius: MedRadius.lgAll, boxShadow: MedShadows.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            decoration: BoxDecoration(
              color: MedColors.surface2,
              border: Border(bottom: BorderSide(color: MedColors.border2)),
              borderRadius: const BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [MedColors.blue, Color(0xFF5BA3EC)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(Icons.medication_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pharmed',
                      style: TextStyle(
                        fontFamily: MedFonts.title,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: MedColors.text,
                      ),
                    ),
                    Text('Sisteme giriş yapın', style: MedTextStyles.bodySm(color: MedColors.text3)),
                  ],
                ),
              ],
            ),
          ),

          // ── Form ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FormField(
                  label: 'E-posta / Kullanıcı Adı',
                  controller: _emailCtrl,
                  placeholder: 'kullanici@hastane.com',
                  onSubmit: _submit,
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Şifre',
                  controller: _passCtrl,
                  placeholder: '••••••••',
                  obscure: true,
                  onSubmit: _submit,
                ),

                if (widget.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: MedColors.redLight,
                      border: Border.all(color: const Color(0xFFF2B3AE)),
                      borderRadius: MedRadius.smAll,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 14, color: MedColors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(widget.errorMessage!, style: MedTextStyles.bodySm(color: MedColors.red)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Giriş butonu
                GestureDetector(
                  onTap: widget.isLoading ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    height: 46,
                    decoration: BoxDecoration(
                      color: widget.isLoading ? MedColors.blue.withAlpha(70) : MedColors.blue,
                      borderRadius: MedRadius.mdAll,
                      boxShadow: const [BoxShadow(color: Color(0x4D1A6BD8), blurRadius: 8, offset: Offset(0, 3))],
                    ),
                    alignment: Alignment.center,
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.login_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 8),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Form Field
// ─────────────────────────────────────────────────────────────────

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
          style: const TextStyle(
            fontFamily: MedFonts.sans,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: MedColors.text2,
          ),
        ),
        const SizedBox(height: 6),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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

// ─────────────────────────────────────────────────────────────────
// Arka plan deseni
// ─────────────────────────────────────────────────────────────────

class _BackgroundPattern extends StatelessWidget {
  const _BackgroundPattern();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _GridPainter()));
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDE3EC).withOpacity(0.4)
      ..strokeWidth = 0.5;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────
// Versiyon etiketi
// ─────────────────────────────────────────────────────────────────

class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    return Text('Pharmed Manager v1.0.0', style: MedTextStyles.monoXs(color: MedColors.text4));
  }
}
