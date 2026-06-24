// [SWREQ-CORE-004] [IEC 62304 §5.5]
// Uygulama giriş yönlendirici.
// Önce auth kontrolü, ardından setup kontrolü yapılır.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth.dart';
import '../../features/dashboard/dashboard.dart';
import '../setup/app_setup_notifier.dart';
import '../../features/setup_wizard/view/setup_wizard_screen.dart';

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final setupState = ref.watch(appSetupStatusProvider);

    // ──────────────────────────────────────────────────────────────
    // [GEÇİCİ - DEV] Setup wizard geliştirmesi için: login olunca
    // setup durumundan bağımsız olarak her zaman SetupWizard'a git.
    // Geliştirme bitince aşağıdaki blok silinip alttaki orijinal
    // switch yorumdan çıkarılacak.
    // ──────────────────────────────────────────────────────────────
    // return switch (authState) {
    //   AuthLoggedOut() => const LoginScreen(),
    //   AuthError() => const LoginScreen(),
    //   AuthLoading() => const LoginScreen(),
    //   AuthLoggedIn() => const SetupWizardScreen(),
    //   AuthSessionExpiring() => const SetupWizardScreen(),
    //   _ => const LoginScreen(),
    // };

    // ──────────────────────────────────────────────────────────────
    // [ORİJİNAL AKIŞ] Dev geçici blok kaldırılınca aşağısı aktif edilecek.
    // ──────────────────────────────────────────────────────────────
    return switch ((authState, setupState)) {
      (AuthLoggedIn(), AsyncLoading()) => const LoginScreen(),
      (AuthLoggedIn(), AsyncData(value: false)) => const SetupWizardScreen(),
      (AuthLoggedIn(), AsyncData(value: true)) => const DashboardScreen(),
      (AuthLoggedIn(), AsyncError()) => const SetupWizardScreen(),

      // Countdown sırasında dashboard'da kal, banner gösterilir
      (AuthSessionExpiring(), _) => const DashboardScreen(),

      // YENİ: Locked çıkış → dashboard'da kal, appbar'da Giriş Yap butonu
      (AuthLoggedOut(showLockedDashboard: true), _) => const DashboardScreen(),

      // Diğer logout/error → login
      (AuthLoggedOut(), _) => const LoginScreen(),
      (AuthError(), _) => const LoginScreen(),
      (AuthLoading(), _) => const LoginScreen(),
      _ => const LoginScreen(),
    };
  }
}
