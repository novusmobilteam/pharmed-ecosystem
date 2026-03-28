// lib/features/setup_wizard/domain/model/cabin_setup_config.dart
//
// [SWREQ-SETUP-001] [IEC 62304 §5.5]
// İlk kurulum wizard'ı — domain modelleri.
// Kabin tipi, temel bilgiler, hizmet kapsamı ve çekmece yapısını temsil eder.
// Sınıf: Class B

import 'package:equatable/equatable.dart';
import '../../../../core/enums/cabinet_type.dart';

// ─────────────────────────────────────────────────────────────────
// Çekmece tipi (Standart kabin için)
// ─────────────────────────────────────────────────────────────────

enum DrawerType {
  cubic4x4, // Kübik 4×4
  cubic4x5, // Kübik 4×5
  unitDose, // Birim Doz
}

extension DrawerTypeExt on DrawerType {
  String get label => switch (this) {
    DrawerType.cubic4x4 => 'Kübik (4×4)',
    DrawerType.cubic4x5 => 'Kübik (4×5)',
    DrawerType.unitDose => 'Birim Doz',
  };
}

// ─────────────────────────────────────────────────────────────────
// Temel bağlantı bilgileri (Adım 2)
// ─────────────────────────────────────────────────────────────────

class WizardBasicInfo extends Equatable {
  const WizardBasicInfo({
    required this.cabinName,
    required this.ipAddress,
    this.dvrIp,
    this.location = '',
    this.port,
    this.timeoutSeconds = 30,
  });

  final String cabinName;
  final String ipAddress;
  final String location;
  final String? dvrIp;
  final String? port;
  final int timeoutSeconds;

  WizardBasicInfo copyWith({
    String? cabinName,
    String? ipAddress,
    String? location,
    String? port,
    int? timeoutSeconds,
    String? dvrIp,
  }) {
    return WizardBasicInfo(
      cabinName: cabinName ?? this.cabinName,
      ipAddress: ipAddress ?? this.ipAddress,
      location: location ?? this.location,
      port: port ?? this.port,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      dvrIp: dvrIp ?? this.dvrIp,
    );
  }

  @override
  List<Object?> get props => [cabinName, ipAddress, location, port, timeoutSeconds, dvrIp];
}

// ─────────────────────────────────────────────────────────────────
// Hizmet kapsamı (Adım 3) — sealed
// ─────────────────────────────────────────────────────────────────

sealed class ServiceScope extends Equatable {
  const ServiceScope();
}

/// Standart kabin → servis bazlı (Kardiyoloji, Dahiliye vb.)
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
// Çekmece konfigürasyonu (Adım 4) — sealed
// ─────────────────────────────────────────────────────────────────

sealed class DrawerConfig extends Equatable {
  const DrawerConfig();
}

/// Standart kabin → tarama sonucu veya manuel
final class StandardDrawerConfig extends DrawerConfig {
  const StandardDrawerConfig({
    required this.sections,
    required this.drawerType,
    this.depth = 6,
    this.splitConfig = '',
    this.scannedFromDevice = false,
  });

  final int sections; // 1–5
  final DrawerType drawerType;
  final int depth; // Birim doz derinliği (1–12)
  final String splitConfig; // "Tek (5)" / "2+3" vb.
  final bool scannedFromDevice;

  StandardDrawerConfig copyWith({
    int? sections,
    DrawerType? drawerType,
    int? depth,
    String? splitConfig,
    bool? scannedFromDevice,
  }) {
    return StandardDrawerConfig(
      sections: sections ?? this.sections,
      drawerType: drawerType ?? this.drawerType,
      depth: depth ?? this.depth,
      splitConfig: splitConfig ?? this.splitConfig,
      scannedFromDevice: scannedFromDevice ?? this.scannedFromDevice,
    );
  }

  @override
  List<Object?> get props => [sections, drawerType, depth, splitConfig, scannedFromDevice];
}

/// Mobil kabin → her sıra için ayrı çekmece tanımı
final class MobileDrawerConfig extends DrawerConfig {
  const MobileDrawerConfig({required this.drawerCount, required this.rows});

  final int drawerCount; // Toplam çekmece (2–8)
  final List<MobileDrawerRow> rows;

  MobileDrawerConfig copyWith({int? drawerCount, List<MobileDrawerRow>? rows}) {
    return MobileDrawerConfig(drawerCount: drawerCount ?? this.drawerCount, rows: rows ?? this.rows);
  }

  @override
  List<Object?> get props => [drawerCount, rows];
}

class MobileDrawerRow extends Equatable {
  const MobileDrawerRow({required this.rowIndex, required this.drawerType, this.columns = 2});

  final int rowIndex;
  final DrawerType drawerType;
  final int columns;

  MobileDrawerRow copyWith({DrawerType? drawerType, int? columns}) {
    return MobileDrawerRow(
      rowIndex: rowIndex,
      drawerType: drawerType ?? this.drawerType,
      columns: columns ?? this.columns,
    );
  }

  @override
  List<Object?> get props => [rowIndex, drawerType, columns];
}

// ─────────────────────────────────────────────────────────────────
// Tamamlanmış kurulum konfigürasyonu
// ─────────────────────────────────────────────────────────────────

class CabinSetupConfig extends Equatable {
  const CabinSetupConfig({
    required this.cabinetType,
    required this.basicInfo,
    required this.serviceScope,
    required this.drawerConfig,
  });

  final CabinetType cabinetType;
  final WizardBasicInfo basicInfo;
  final ServiceScope serviceScope;
  final DrawerConfig drawerConfig;

  @override
  List<Object?> get props => [cabinetType, basicInfo, serviceScope, drawerConfig];
}
