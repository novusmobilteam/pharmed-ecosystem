// lib/core/router/app_router.dart
//
// [SWREQ-CORE-004] [IEC 62304 §5.5]
// Uygulama giriş yönlendirici.
// Önce auth kontrolü, ardından setup kontrolü yapılır.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_manager/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:pharmed_manager/features/auth/presentation/screen/login_screen.dart';
import 'package:pharmed_manager/features/auth/presentation/state/auth_state.dart';
import 'package:pharmed_manager/features/dashboard/presentation/view/dashboard_screen.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // AuthNotifier içindeki bir getter yardımıyla:
    // Eğer kullanıcı daha önce giriş yapmışsa ve biz Dashboard'daysak,
    // logout olsa bile dashboard'da kalmaya devam etmeli.
    final authNotif = ref.read(authNotifierProvider.notifier);
    final hasSessionHistory = authNotif.hasAccessedDashboard;

    return switch ((authState)) {
      AuthLoggedOut() when hasSessionHistory => const DashboardScreen(),
      AuthLoggedOut() => const LoginScreen(),
      AuthError() => const LoginScreen(),
      AuthLoading() => const _SplashView(),
      AuthLoggedIn() => const DashboardScreen(),
      AuthSessionExpiring() => DashboardScreen(),
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
