// [SWREQ-CORE-004] [IEC 62304 §5.5]
// Uygulama giriş yönlendirici.
// Önce auth kontrolü, ardından setup kontrolü yapılır.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth.dart';
import '../setup/app_setup_notifier.dart';
import '../../features/setup_wizard/view/setup_wizard_screen.dart';
import '../../features/dashboard/presentation/view/dashboard_screen.dart';

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final setupState = ref.watch(appSetupStatusProvider);

    return switch ((authState, setupState)) {
      // Auth yok → direkt login
      (AuthLoggedOut(), _) => const LoginScreen(),
      //(AuthLoggedOut(), _) when hasSessionHistory => const DashboardScreen(),
      (AuthError(), _) => const LoginScreen(),

      // Auth yükleniyor
      (AuthLoading(), _) => const LoginScreen(),

      // Auth tamam — setup kontrol et
      (AuthLoggedIn(), AsyncLoading()) => const LoginScreen(),
      (AuthLoggedIn(), AsyncData(value: false)) => const SetupWizardScreen(),
      (AuthLoggedIn(), AsyncData(value: true)) => const DashboardScreen(),
      (AuthLoggedIn(), AsyncError()) => const SetupWizardScreen(),

      // Oturum bitiyor — dashboard'da kal, banner gösterilir
      (AuthSessionExpiring(), AsyncData(value: true)) => const DashboardScreen(),
      (AuthSessionExpiring(), _) => const DashboardScreen(),

      // Diğer
      _ => const LoginScreen(),
    };
  }
}
