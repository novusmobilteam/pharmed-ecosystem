// [SWREQ-SETUP-UI-011] [IEC 62304 §5.5]
// Setup Wizard Adım 4 — mobil kabin çekmece yapılandırma state tanımları.
// Sınıf: Class B

import '../../domain/entity/wizard_mobile_layout.dart';

class Step4MobileState {
  Step4MobileState({
    WizardMobileLayout? mobileLayout,
    this.portDiscoveryState = PortDiscoveryState.idle,
    this.portDiscoveryError,
    this.discoveredPorts = const [],
  }) : mobileLayout = mobileLayout ?? WizardMobileLayout.defaultLayout();

  final WizardMobileLayout mobileLayout;
  final PortDiscoveryState portDiscoveryState;
  final String? portDiscoveryError;
  final List<int> discoveredPorts;

  bool get isComplete => mobileLayout.drawerCount > 0 && portDiscoveryState == PortDiscoveryState.discovered;

  bool get hasInactiveDrawers =>
      portDiscoveryState == PortDiscoveryState.discovered && mobileLayout.inactiveDrawerCount > 0;

  Step4MobileState copyWith({
    WizardMobileLayout? mobileLayout,
    PortDiscoveryState? portDiscoveryState,
    String? portDiscoveryError,
    List<int>? discoveredPorts,
  }) {
    return Step4MobileState(
      mobileLayout: mobileLayout ?? this.mobileLayout,
      portDiscoveryState: portDiscoveryState ?? this.portDiscoveryState,
      portDiscoveryError: portDiscoveryError ?? this.portDiscoveryError,
      discoveredPorts: discoveredPorts ?? this.discoveredPorts,
    );
  }
}

enum PortDiscoveryState {
  /// Keşif henüz başlatılmadı
  idle,

  /// Portlar taranıyor — her port için açma komutu gönderiliyor
  discovering,

  /// Keşif tamamlandı — sonuç mobileLayout'a işlendi
  discovered,

  /// Keşif başarısız — bağlantı veya donanım hatası
  error,
}
