// lib/core/router/app_router.dart
//
// [SWREQ-CORE-004] [IEC 62304 §5.5]
// Uygulama giriş yönlendirici.
// İlk çalıştırma kontrolü: kurulum tamamsa Dashboard, değilse SetupWizard.
// SetupWizard tamamlanınca markComplete() çağrılır → otomatik geçiş.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cache/app_settings_cache.dart';
import '../../features/setup_wizard/presentation/screen/setup_wizard_screen.dart';
import '../../features/dashboard/presentation/screen/dashboard_screen.dart';
import '../../shared/widgets/atoms/med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────

/// [SWREQ-CORE-004] Kurulum durumu.
/// AsyncLoading → Hive okunuyor
/// AsyncData(false) → ilk çalıştırma, wizard açılır
/// AsyncData(true)  → kurulum tamamlı, dashboard açılır
final appSetupStatusProvider =
    AsyncNotifierProvider<AppSetupStatusNotifier, bool>(
  AppSetupStatusNotifier.new,
);

class AppSetupStatusNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => appSettingsCache.isSetupComplete();

  /// Wizard tamamlandığında çağrılır → AppRouter dashboarda geçer.
  void markComplete() {
    state = const AsyncData(true);
  }
}

// ─────────────────────────────────────────────────────────────────
// AppRouter
// ─────────────────────────────────────────────────────────────────

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(appSetupStatusProvider);

    return switch (status) {
      AsyncData(:final value) =>
        value ? const DashboardScreen() : const SetupWizardScreen(),
      AsyncError() => const SetupWizardScreen(),
      _ => const _SplashView(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────
// Splash — Hive okunurken gösterilir
// ─────────────────────────────────────────────────────────────────

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: MedColors.bg,
      body: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(MedColors.blue),
        ),
      ),
    );
  }
}
