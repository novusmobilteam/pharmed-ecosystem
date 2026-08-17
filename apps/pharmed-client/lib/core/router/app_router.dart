// [SWREQ-CORE-004] [IEC 62304 §5.5]
// Uygulama giriş yönlendirici.
// Önce auth kontrolü, ardından setup kontrolü yapılır.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/auth.dart';
import '../../features/dashboard/dashboard.dart';
import '../setup/app_setup_notifier.dart';
import '../../features/setup_wizard/view/setup_wizard_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthNotifier>().state;
    final setup = context.watch<AppSetupStatusNotifier>();

    // ──────────────────────────────────────────────────────────────
    // [GEÇİCİ - DEV] ... (aynı, dokunulmadı)
    // ──────────────────────────────────────────────────────────────

    // TODO : Düzellttttttt
    return switch (authState) {
      AuthLoggedIn() when setup.isLoading => const LoginScreen(),
      // AuthLoggedIn() when setup.error != null => const SetupWizardScreen(),
      // AuthLoggedIn() when setup.isSetupComplete == false => const SetupWizardScreen(),
      AuthLoggedIn() when setup.isSetupComplete == true => const DashboardScreen(),

      // Countdown sırasında dashboard'da kal, banner gösterilir
      AuthSessionExpiring() => const DashboardScreen(),

      // Locked çıkış → dashboard'da kal, appbar'da Giriş Yap butonu
      AuthLoggedOut(showLockedDashboard: true) => const DashboardScreen(),

      // Diğer logout/error → login
      AuthLoggedOut() => const LoginScreen(),
      AuthError() => const LoginScreen(),
      AuthLoading() => const LoginScreen(),
      _ => const LoginScreen(),
    };
  }
}
