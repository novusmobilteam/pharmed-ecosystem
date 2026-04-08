// lib/core/router/app_router.dart
//
// [SWREQ-CORE-004] [IEC 62304 §5.5]
// Uygulama giriş yönlendirici.
// Önce auth kontrolü, ardından setup kontrolü yapılır.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:pharmed_manager/features/auth/presentation/screen/login_screen.dart';
import 'package:pharmed_manager/features/auth/presentation/state/auth_state.dart';
import 'package:pharmed_manager/features/home/view/home_screen.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthNotifier>().state;

    return switch (authState) {
      AuthLoggedOut() => const LoginScreen(),
      AuthLoading() => const _SplashView(),
      AuthLoggedIn() => const HomeScreen(),
      AuthError() => const LoginScreen(),
      AuthSessionExpiring() => const LoginScreen(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────
// Splash — async işlemler tamamlanana kadar gösterilir
// ─────────────────────────────────────────────────────────────────

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: MedColors.bg,
      body: Center(
        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(MedColors.blue)),
      ),
    );
  }
}
