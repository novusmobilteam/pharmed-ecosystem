// [SWREQ-SETUP-UI-011] [IEC 62304 §5.5]
// Setup Wizard Adım 4 — mobil kabin çekmece yapılandırma state yöneticisi.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../domain/entity/wizard_mobile_layout.dart';
import '../../domain/usecase/scan_mobile_drawer_ports_usecase.dart';
import '../notifier/step2_notifier.dart';
import '../state/step4_mobile_state.dart';

final step4MobileNotifierProvider = NotifierProvider<Step4MobileNotifier, Step4MobileState>(Step4MobileNotifier.new);

class Step4MobileNotifier extends Notifier<Step4MobileState> {
  @override
  Step4MobileState build() => Step4MobileState();

  // ── Çekmece konfigürasyonu ────────────────────────────────────────────────

  /// [SWREQ-SETUP-UI-012]
  void updateDrawerCount(int count) {
    state = state.copyWith(mobileLayout: state.mobileLayout.withDrawerCount(count));
  }

  /// [SWREQ-SETUP-UI-013]
  void updateDrawerConfig(int drawerIndex, List<int> rowColumns) {
    state = state.copyWith(mobileLayout: state.mobileLayout.withDrawerConfig(drawerIndex, rowColumns));
  }

  /// [SWREQ-SETUP-UI-015]
  void toggleSameConfig({required bool value}) {
    state = state.copyWith(mobileLayout: state.mobileLayout.withSameConfig(value));
  }

  void removeInactiveDrawer(int drawerIndex) {
    state = state.copyWith(mobileLayout: state.mobileLayout.removeInactiveDrawer(drawerIndex));
  }

  /// [SWREQ-SETUP-HW-001]
  Future<void> discoverPorts() async {
    final comPort = ref.read(step2NotifierProvider).basicInfo?.comPort;
    if (comPort == null || comPort.isEmpty) return;

    if (state.mobileLayout.drawerCount == 0) return;

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-HW-001',
      message: 'Mobil kabin port keşfi başlatıldı',
      context: {'comPort': comPort, 'expectedDrawers': state.mobileLayout.drawerCount},
    );

    state = state.copyWith(
      portDiscoveryState: PortDiscoveryState.discovering,
      portDiscoveryError: null,
      discoveredPorts: [],
    );

    final result = await ref
        .read(scanMobileDrawerPortsUseCaseProvider)
        .call(
          targetPort: comPort,
          onPortDiscovered: (portNumber) {
            state = state.copyWith(discoveredPorts: [...state.discoveredPorts, portNumber]);
          },
        );

    result.when(
      ok: (discovery) {
        if (discovery.isEmpty) {
          MedLogger.error(
            unit: 'SW-UNIT-SETUP',
            swreq: 'SWREQ-SETUP-HW-001',
            message: 'Port keşfi başarısız: Hiç aktif port bulunamadı',
          );
          state = state.copyWith(
            portDiscoveryState: PortDiscoveryState.error,
            portDiscoveryError:
                'Hiç aktif port bulunamadı. '
                'Solenoid bağlantılarını ve kablo durumunu kontrol edin.',
          );
          return;
        }

        final updatedLayout = state.mobileLayout.applyDiscoveredPorts(discovery.activePorts);

        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-HW-001',
          message: 'Port keşfi tamamlandı',
          context: {'activePorts': discovery.activePorts, 'inactiveDrawers': updatedLayout.inactiveDrawerCount},
        );

        state = state.copyWith(
          portDiscoveryState: PortDiscoveryState.discovered,
          discoveredPorts: discovery.activePorts,
          mobileLayout: updatedLayout,
        );
      },
      error: (e) {
        MedLogger.error(unit: 'SW-UNIT-SETUP', swreq: 'SWREQ-SETUP-HW-001', message: 'Port keşfi başarısız', error: e);
        state = state.copyWith(portDiscoveryState: PortDiscoveryState.error, portDiscoveryError: e.message);
      },
    );
  }

  /// [SWREQ-SETUP-HW-002]
  void resetPortDiscovery() {
    final resetDrawers = state.mobileLayout.drawers
        .map(
          (d) => WizardDrawerConfig(
            drawerIndex: d.drawerIndex,
            rowColumns: d.rowColumns,
            portNumber: null,
            isActive: true,
          ),
        )
        .toList();

    state = state.copyWith(
      portDiscoveryState: PortDiscoveryState.idle,
      portDiscoveryError: null,
      discoveredPorts: [],
      mobileLayout: state.mobileLayout.copyWith(drawers: resetDrawers),
    );
  }
}
