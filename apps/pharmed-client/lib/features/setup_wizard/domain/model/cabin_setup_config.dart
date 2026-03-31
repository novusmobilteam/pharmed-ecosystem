// lib/features/setup_wizard/domain/model/cabin_setup_config.dart
//
// [SWREQ-SETUP-001] [IEC 62304 §5.5]
// İlk kurulum wizard'ı — domain modelleri.
// Sınıf: Class B

import 'package:equatable/equatable.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'wizard_mobile_layout.dart';

// ─────────────────────────────────────────────────────────────────
// Temel bağlantı bilgileri (Adım 2)
// ─────────────────────────────────────────────────────────────────

class WizardBasicInfo extends Equatable {
  const WizardBasicInfo({
    required this.cabinName,
    required this.location,
    this.ipAddress = '',
    this.comPort,
    this.dvrIp,
    this.timeoutSeconds = 30,
  });

  final String cabinName;
  final String location;
  final String ipAddress;
  final String? comPort;
  final String? dvrIp;
  final int timeoutSeconds;

  WizardBasicInfo copyWith({
    String? cabinName,
    String? location,
    String? ipAddress,
    String? comPort,
    String? dvrIp,
    int? timeoutSeconds,
  }) {
    return WizardBasicInfo(
      cabinName: cabinName ?? this.cabinName,
      location: location ?? this.location,
      ipAddress: ipAddress ?? this.ipAddress,
      comPort: comPort ?? this.comPort,
      dvrIp: dvrIp ?? this.dvrIp,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    );
  }

  @override
  List<Object?> get props => [cabinName, location, ipAddress, comPort, dvrIp, timeoutSeconds];
}

// ─────────────────────────────────────────────────────────────────
// Hizmet kapsamı (Adım 3) — sealed
// ─────────────────────────────────────────────────────────────────

sealed class ServiceScope extends Equatable {
  const ServiceScope();
}

/// Standart kabin → servis bazlı
final class ServiceBased extends ServiceScope {
  const ServiceBased({required this.serviceName, this.departmentId});

  final String serviceName;
  final String? departmentId;

  @override
  List<Object?> get props => [serviceName, departmentId];
}

/// Mobil kabin → oda listesi bazlı
final class RoomBased extends ServiceScope {
  const RoomBased({required this.rooms});

  final List<String> rooms;

  @override
  List<Object?> get props => [rooms];
}

// ─────────────────────────────────────────────────────────────────
// Tamamlanmış kurulum konfigürasyonu
// ─────────────────────────────────────────────────────────────────

class CabinSetupConfig extends Equatable {
  const CabinSetupConfig({
    required this.cabinetType,
    required this.basicInfo,
    required this.serviceScope,
    this.scannedLayout,
    this.mobileLayout,
  });

  final CabinType cabinetType;
  final WizardBasicInfo basicInfo;
  final ServiceScope serviceScope;

  /// Standart kabin scan sonucu
  final List<DrawerGroup>? scannedLayout;

  /// Mobil kabin manuel tanım
  final WizardMobileLayout? mobileLayout;

  @override
  List<Object?> get props => [cabinetType, basicInfo, serviceScope, scannedLayout, mobileLayout];
}
