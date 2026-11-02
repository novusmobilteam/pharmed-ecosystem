import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../auth/auth.dart';
import '../../dashboard/dashboard.dart';
import '../view/service_selection_screen.dart';
import '../view/station_access_denied_screen.dart';
import 'active_service_notifier.dart';

/// [SWREQ-CORE-AUTH-002] Login sonrası ilk kapı:
///   1) Kullanıcının güncel istasyonda yetkisi var mı? (yoksa → StationAccessDeniedScreen)
///   2) İstasyon birden fazla servise hizmet veriyor mu? (evet → ServiceSelectionScreen)
///   3) Dashboard
/// Yetki doğrulanmadan (unknown) hiçbir koşulda 2. ve 3. adıma geçilmez.
class ActiveServiceGate extends ConsumerStatefulWidget {
  const ActiveServiceGate({super.key});

  @override
  ConsumerState<ActiveServiceGate> createState() => _ActiveServiceGateState();
}

class _ActiveServiceGateState extends ConsumerState<ActiveServiceGate> {
  void _initialize(AppUser user) => ref.read(activeServiceNotifierProvider).initialize(user);

  void _logout() => ref.read(authNotifierProvider.notifier).logout();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final activeService = ref.watch(activeServiceNotifierProvider);

    // Router bu widget'ı yalnızca AuthLoggedIn'de gösterir; yine de savunma.
    if (authState is! AuthLoggedIn) return const _GateLoading();
    final user = authState.user;

    // Kontrol bu kullanıcı için hiç başlatılmadıysa başlat.
    if (activeService.checkedUserId != user.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final n = ref.read(activeServiceNotifierProvider);
        if (n.checkedUserId != user.id && !n.isLoadingServices) _initialize(user);
      });
      return const _GateLoading();
    }

    switch (activeService.accessStatus) {
      case StationAccessStatus.unknown:
        if (!activeService.isLoadingServices && activeService.hasLoadError) {
          return StationAccessVerifyErrorScreen(onRetry: () => _initialize(user), onLogout: _logout);
        }
        return const _GateLoading();

      case StationAccessStatus.denied:
        return StationAccessDeniedScreen(user: user, station: activeService.station, onLogout: _logout);

      case StationAccessStatus.granted:
        if (activeService.requiresSelection) return const ServiceSelectionScreen();
        return const DashboardScreen();
    }
  }
}

class _GateLoading extends StatelessWidget {
  const _GateLoading();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: MedLoadingIndicator()));
}
