// lib/features/setup_wizard/data/repository/setup_wizard_repository_impl.dart
//
// [SWREQ-SETUP-DATA-006]
// Repository implementasyonu — domain modeli ↔ DTO dönüşümü burada.
// Sınıf: Class B

import 'package:result_dart/result_dart.dart';
import '../../domain/model/cabin_setup_config.dart';
import '../../domain/model/wizard_draft.dart';
import '../datasource/setup_wizard_datasource.dart';
import '../dto/cabin_config_dto.dart';

class SetupWizardRepositoryImpl {
  const SetupWizardRepositoryImpl({required this.dataSource});

  final SetupWizardDataSource dataSource;

  // ── Kaydet ──────────────────────────────────────────────────────

  Future<Result<int>> saveCabinConfig(CabinSetupConfig config) async {
    final dto = _toDto(config);
    final result = await dataSource.saveCabinConfig(dto);
    return result.fold((saved) => Success(saved.id ?? 0), Failure.new);
  }

  // ── Cihaz tarama ────────────────────────────────────────────────

  Future<Result<StandardDrawerConfig>> scanDeviceDrawerConfig(String ipAddress) async {
    final result = await dataSource.scanDeviceDrawerConfig(ipAddress);
    return result.fold((dto) => Success(_toStandardDrawerConfig(dto)), Failure.new);
  }

  // ── DTO dönüştürücüler ───────────────────────────────────────────

  CabinConfigDto _toDto(CabinSetupConfig config) {
    final scope = config.serviceScope;
    final drw = config.drawerConfig;

    return CabinConfigDto(
      cabinetType: config.cabinetType.name,
      cabinName: config.basicInfo.cabinName,
      location: config.basicInfo.location,
      ipAddress: config.basicInfo.ipAddress,
      port: config.basicInfo.port,
      timeoutSeconds: config.basicInfo.timeoutSeconds,
      serviceName: scope is ServiceBased ? scope.serviceName : null,
      departmentId: scope is ServiceBased ? scope.departmentId : null,
      rooms: scope is RoomBased ? scope.rooms : null,
      sections: drw is StandardDrawerConfig ? drw.sections : null,
      drawerType: drw is StandardDrawerConfig ? drw.drawerType.name : null,
      depth: drw is StandardDrawerConfig ? drw.depth : null,
      splitConfig: drw is StandardDrawerConfig ? drw.splitConfig : null,
      mobileDrawers: drw is MobileDrawerConfig
          ? drw.rows
                .map((r) => {'rowIndex': r.rowIndex, 'drawerType': r.drawerType.name, 'columns': r.columns})
                .toList()
          : null,
    );
  }

  StandardDrawerConfig _toStandardDrawerConfig(CabinConfigDto dto) {
    return StandardDrawerConfig(
      sections: dto.sections ?? 5,
      drawerType: _parseDrawerType(dto.drawerType),
      depth: dto.depth ?? 6,
      splitConfig: dto.splitConfig ?? '',
      scannedFromDevice: true,
    );
  }

  DrawerType _parseDrawerType(String? raw) {
    return switch (raw) {
      'cubic4x5' => DrawerType.cubic4x5,
      'unitDose' => DrawerType.unitDose,
      _ => DrawerType.cubic4x4,
    };
  }
}

// ── WizardDraft → CabinSetupConfig yardımcısı ────────────────────

extension WizardDraftX on WizardDraft {
  CabinSetupConfig toConfig() {
    assert(isComplete);
    return CabinSetupConfig(
      cabinetType: cabinetType!,
      basicInfo: basicInfo!,
      serviceScope: serviceScope!,
      drawerConfig: drawerConfig!,
    );
  }
}
