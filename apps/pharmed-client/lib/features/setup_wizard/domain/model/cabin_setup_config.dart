// [SWREQ-SETUP-001] [IEC 62304 §5.5]
// İlk kurulum wizard'ı — domain modelleri.
// Sınıf: Class B

import 'package:equatable/equatable.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'wizard_mobile_layout.dart';

class WizardBasicInfo extends Equatable {
  const WizardBasicInfo({
    required this.cabinName,
    this.ipAddress = '',
    this.comPort,
    this.dvrIp,
    this.rfidEnable = false,
    this.rfidIpAddress,
    this.rfidPort,
  });

  final String cabinName;
  final String ipAddress;
  final String? comPort;
  final String? dvrIp;
  final bool rfidEnable;
  final String? rfidIpAddress;
  final String? rfidPort;

  WizardBasicInfo copyWith({
    String? cabinName,
    String? location,
    String? ipAddress,
    String? comPort,
    String? dvrIp,
    int? timeoutSeconds,
    bool? rfidEnable,
    String? rfidIpAddress,
    String? rfidPort,
  }) {
    return WizardBasicInfo(
      cabinName: cabinName ?? this.cabinName,
      ipAddress: ipAddress ?? this.ipAddress,
      comPort: comPort ?? this.comPort,
      dvrIp: dvrIp ?? this.dvrIp,
      rfidEnable: rfidEnable ?? this.rfidEnable,
      rfidIpAddress: rfidIpAddress ?? this.rfidIpAddress,
      rfidPort: rfidPort ?? this.rfidPort,
    );
  }

  @override
  List<Object?> get props => [cabinName, ipAddress, comPort, dvrIp, rfidEnable, rfidIpAddress, rfidPort];
}

sealed class StationScope extends Equatable {
  const StationScope(this.station);

  final Station station;
}

/// Standart kabin → servis bazlı
final class StandartScope extends StationScope {
  const StandartScope(super.station);

  @override
  List<Object?> get props => [station];
}

/// Mobil kabin → oda listesi bazlı
final class MobileScope extends StationScope {
  const MobileScope(super.station, {required this.rooms, required this.beds});

  final List<Room> rooms;
  final List<Bed> beds;

  @override
  List<Object?> get props => [station, rooms, beds];
}

class CabinSetupConfig extends Equatable {
  const CabinSetupConfig({
    required this.cabinetType,
    required this.basicInfo,
    required this.stationScope,
    this.scannedLayout,
    this.mobileLayout,
  });

  final CabinType cabinetType;
  final WizardBasicInfo basicInfo;
  final StationScope stationScope;

  /// Standart kabin scan sonucu
  final List<DrawerGroup>? scannedLayout;

  /// Mobil kabin manuel tanım
  final WizardMobileLayout? mobileLayout;

  @override
  List<Object?> get props => [cabinetType, basicInfo, stationScope, scannedLayout, mobileLayout];
}
