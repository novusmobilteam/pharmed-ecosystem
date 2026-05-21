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
import '../notifier/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();
    final authState = context.watch<AuthNotifier>().state;

    return Scaffold(
      backgroundColor: MedColors.bg,
      body: Center(
        child: LoginModal(
          isLoading: authState is AuthLoading,
          onLogin: (email, password, onError) async {
            await authNotifier.login(email: email, password: password, onError: onError);
          },
        ),
      ),
    );
  }
}
