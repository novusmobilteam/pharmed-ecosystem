// [SWREQ-CORE-004] [IEC 62304 §5.5]
// Uygulama giriş yönlendirici.
// Önce auth kontrolü, ardından setup kontrolü yapılır.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../features/auth/auth.dart';
import '../../features/dashboard/dashboard.dart';
import '../../features/service_selection/notifier/active_service_gate.dart';
import '../setup/app_setup_notifier.dart';
import '../../features/setup_wizard/view/setup_wizard_screen.dart';

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final setupState = ref.watch(appSetupStatusProvider);

    return switch ((authState, setupState)) {
      // Oturum açık — geri sayım sırasında da bu dal çalışır (countdown
      // AuthState'te değil), ağaç yapısı sabit kalır.
      (AuthLoggedIn(), AsyncData(value: true)) => const ActiveServiceGate(),
      (AuthLoggedIn(), AsyncData(value: false)) => const SetupWizardScreen(),
      (AuthLoggedIn(), AsyncError()) => const SetupWizardScreen(),
      (AuthLoggedIn(), _) => const Scaffold(body: Center(child: MedLoadingIndicator())),

      // Kilitli bağlam — timeout/401 sonrası ve oradan yapılan giriş denemesi
      // (yükleniyor/hata) boyunca dashboard korunur.
      (AuthLoggedOut(showLockedDashboard: true), _) ||
      (AuthLoading(showLockedDashboard: true), _) ||
      (AuthError(showLockedDashboard: true), _) => const DashboardScreen(),

      // Diğer her durum → login
      _ => const LoginScreen(),
    };
  }
}
