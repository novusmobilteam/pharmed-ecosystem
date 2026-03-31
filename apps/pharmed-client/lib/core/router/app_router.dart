// lib/core/router/app_router.dart
//
// [SWREQ-CORE-004] [IEC 62304 §5.5]
// Uygulama giriş yönlendirici.
// Önce auth kontrolü, ardından setup kontrolü yapılır.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/auth/presentation/screen/login_screen.dart';

import '../setup/app_setup_notifier.dart';
import '../../features/auth/presentation/notifier/auth_notifier.dart';
import '../../features/auth/presentation/state/auth_state.dart';
import '../../features/setup_wizard/presentation/view/setup_wizard_screen.dart';
import '../../features/dashboard/presentation/screen/dashboard_screen.dart';
import '../../shared/widgets/atoms/med_tokens.dart';

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final setupState = ref.watch(appSetupStatusProvider);

    return switch ((authState, setupState)) {
      // Auth yok → direkt login
      (AuthLoggedOut(), _) => const LoginScreen(),
      (AuthError(), _) => const LoginScreen(),

      // Auth yükleniyor
      (AuthLoading(), _) => const _SplashView(),

      // Auth tamam — setup kontrol et
      (AuthLoggedIn(), AsyncLoading()) => const _SplashView(),
      (AuthLoggedIn(), AsyncData(value: false)) => const SetupWizardScreen(),
      (AuthLoggedIn(), AsyncData(value: true)) => const DashboardScreen(),
      (AuthLoggedIn(), AsyncError()) => const SetupWizardScreen(),

      // Oturum bitiyor — dashboard'da kal, banner gösterilir
      (AuthSessionExpiring(), AsyncData(value: true)) => const DashboardScreen(),
      (AuthSessionExpiring(), _) => const DashboardScreen(),

      // Diğer
      _ => const _SplashView(),
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
