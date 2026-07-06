import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'providers.dart';

final userRepositoryProvider = Provider<IUserReader>((ref) {
  return UserRepositoryImpl(dataSource: ref.read(userRemoteDataSourceProvider), mapper: ref.read(userMapperProvider));
});

final userManagerProvider = Provider<IUserManager>((ref) {
  return UserRepositoryImpl(dataSource: ref.read(userRemoteDataSourceProvider), mapper: ref.read(userMapperProvider));
});

final cabinStockRepositoryProvider = Provider<ICabinStockRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockCabinStockRepository(),
    AppFlavor.dev || AppFlavor.prod => CabinStockRepositoryImpl(
      dataSource: ref.read(cabinStockRemoteDataSourceProvider),
      localDataSource: ref.read(cabinStockLocalDataSourceProvider),
      cabinMapper: CabinStockMapper(),
      stationMapper: StationStockMapper(),
      epcMapper: CabinExpectedEpcMapper(),
    ),
  };
});

final hospitalizationRepositoryProvider = Provider<IHospitalizationRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => HospitalizationRepositoryImpl(
      mapper: HospitalizationMapper(),
      dataSource: ref.read(hospitalizationRemoteDataSourceProvider),
    ),
    AppFlavor.dev || AppFlavor.prod => HospitalizationRepositoryImpl(
      mapper: HospitalizationMapper(),
      dataSource: ref.read(hospitalizationRemoteDataSourceProvider),
    ),
  };
});

final medicineRepositoryProvider = Provider<IMedicineRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MedicineRepositoryImpl(
      dataSource: ref.read(medicineRemoteDataSourceProvider),
      mapper: MedicineMapper(),
      drugMapper: DrugMapper(),
      mcMapper: MedicalConsumableMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => MedicineRepositoryImpl(
      dataSource: ref.read(medicineRemoteDataSourceProvider),
      mapper: MedicineMapper(),
      drugMapper: DrugMapper(),
      mcMapper: MedicalConsumableMapper(),
    ),
  };
});

final prescriptionRepositoryProvider = Provider<IPrescriptionRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => PrescriptionRepositoryImpl(
      prescriptionItemMapper: PrescriptionItemMapper(),
      prescriptionMapper: PrescriptionMapper(),
      prescriptionItemMovementMapper: PrescriptionItemMovementMapper(),
      dataSource: ref.read(prescriptionRemoteDataSourceProvider),
    ),
    AppFlavor.dev || AppFlavor.prod => PrescriptionRepositoryImpl(
      prescriptionItemMapper: PrescriptionItemMapper(),
      prescriptionMapper: PrescriptionMapper(),
      prescriptionItemMovementMapper: PrescriptionItemMovementMapper(),
      dataSource: ref.read(prescriptionRemoteDataSourceProvider),
    ),
  };
});

final stationRepositoryProvider = Provider<IStationRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockStationRepository(),
    AppFlavor.dev || AppFlavor.prod => StationRepositoryImpl(
      dataSource: ref.read(stationRemoteDataSourceProvider),
      mapper: StationMapper(),
    ),
  };
});

final serviceRepositoryProvider = Provider<IServiceRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => ServiceRepositoryImpl(
      dataSource: ref.read(serviceRemoteDataSourceProvider),
      mapper: ServiceMapper(),
      roomMapper: RoomMapper(),
      bedMapper: BedMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => ServiceRepositoryImpl(
      dataSource: ref.read(serviceRemoteDataSourceProvider),
      mapper: ServiceMapper(),
      roomMapper: RoomMapper(),
      bedMapper: BedMapper(),
    ),
  };
});

final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockDashboardRepository(),
    AppFlavor.dev || AppFlavor.prod => DashboardRepositoryImpl(
      dataSource: ref.read(dashboardRemoteDataSourceProvider),
      cabinStockMapper: CabinStockMapper(),
      prescriptionItemMapper: PrescriptionItemMapper(),
      refundMapper: RefundMapper(),
      menuMapper: MenuTreeMapper(),
      cabinMapper: CabinMapper(),
      itemMovementMapper: PrescriptionItemMovementMapper(),
    ),
  };
});

final cabinAssignmentRepositoryProvider = Provider<IAssignmentRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => AssignmentRepositoryImpl(
      dataSource: ref.read(assignmentRemoteDataSourceProvider),
      medicineAssignmentMapper: MedicineAssignmentMapper(),
      patientAssignmentMapper: PatientAssignmentMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => AssignmentRepositoryImpl(
      dataSource: ref.read(assignmentRemoteDataSourceProvider),
      medicineAssignmentMapper: MedicineAssignmentMapper(),
      patientAssignmentMapper: PatientAssignmentMapper(),
    ),
  };
});

final faultRepositoryProvider = Provider<IFaultRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => FaultRepositoryImpl(
      dataSource: ref.read(faultRemoteDataSourceProvider),
      masterFaultMapper: MasterFaultMapper(),
      mobileFaultMapper: MobileFaultMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => FaultRepositoryImpl(
      dataSource: ref.read(faultRemoteDataSourceProvider),
      masterFaultMapper: MasterFaultMapper(),
      mobileFaultMapper: MobileFaultMapper(),
    ),
  };
});

final cabinRepositoryProvider = Provider<ICabinRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => CabinRepositoryImpl(
      cabinMapper: CabinMapper(),
      drawerSlotMapper: DrawerSlotMapper(),
      drawerConfigMapper: DrawerConfigMapper(),
      drawerUnitMapper: DrawerUnitMapper(),
      drawerTypeMapper: DrawerTypeMapper(),
      mobileDrawerSlotMapper: MobileDrawerSlotMapper(),
      remoteDataSource: ref.read(cabinRemoteDataSourceProvider),
      localDataSource: ref.read(cabinLocaleDataSourceProvider),
    ),
    AppFlavor.dev || AppFlavor.prod => CabinRepositoryImpl(
      cabinMapper: CabinMapper(),
      drawerSlotMapper: DrawerSlotMapper(),
      drawerConfigMapper: DrawerConfigMapper(),
      drawerUnitMapper: DrawerUnitMapper(),
      drawerTypeMapper: DrawerTypeMapper(),
      mobileDrawerSlotMapper: MobileDrawerSlotMapper(),
      remoteDataSource: ref.read(cabinRemoteDataSourceProvider),
      localDataSource: ref.read(cabinLocaleDataSourceProvider),
    ),
  };
});

final intakeRepositoryProvider = Provider<IIntakeRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => IntakeRepositoryImpl(
      dataSource: ref.read(intakeDataSourceProvider),
      intakeItemMapper: IntakeItemMapper(),
      patientIntakeItemMapper: PatientIntakeItemMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => IntakeRepositoryImpl(
      dataSource: ref.read(intakeDataSourceProvider),
      intakeItemMapper: IntakeItemMapper(),
      patientIntakeItemMapper: PatientIntakeItemMapper(),
    ),
  };
});

final refundRepositoryProvider = Provider<IRefundRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => RefundRepositoryImpl(
      dataSource: ref.read(refundDataSourceProvider),
      refundMapper: RefundMapper(),
      withdrawItemMapper: IntakeItemMapper(),
      prescriptionMapper: PrescriptionItemMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => RefundRepositoryImpl(
      dataSource: ref.read(refundDataSourceProvider),
      refundMapper: RefundMapper(),
      withdrawItemMapper: IntakeItemMapper(),
      prescriptionMapper: PrescriptionItemMapper(),
    ),
  };
});

final wasteRepositoryProvider = Provider<IWasteRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => WasteRepositoryImpl(
      dataSource: ref.read(wasteDataSourceProvider),
      assignmentMapper: MedicineAssignmentMapper(),
      prescriptionItemMapper: PrescriptionItemMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => WasteRepositoryImpl(
      dataSource: ref.read(wasteDataSourceProvider),
      assignmentMapper: MedicineAssignmentMapper(),
      prescriptionItemMapper: PrescriptionItemMapper(),
    ),
  };
});

final patientRepositoryProvider = Provider<IPatientRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => PatientRepositoryImpl(
      dataSource: ref.read(patientDataSourceProvider),
      patientMapper: PatientMapper(),
      myPatientMapper: MyPatientMapper(),
      urgentPatientMapper: UrgentPatientMapper(),
      hospitalizationMapper: HospitalizationMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => PatientRepositoryImpl(
      dataSource: ref.read(patientDataSourceProvider),
      patientMapper: PatientMapper(),
      myPatientMapper: MyPatientMapper(),
      urgentPatientMapper: UrgentPatientMapper(),
      hospitalizationMapper: HospitalizationMapper(),
    ),
  };
});

final censusRepositoryProvider = Provider<ICensusRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => CensusRepositoryImpl(dataSource: ref.read(censusDataSourceProvider)),
    AppFlavor.dev || AppFlavor.prod => CensusRepositoryImpl(dataSource: ref.read(censusDataSourceProvider)),
  };
});

final unloadRepositoryProvider = Provider<IUnloadRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => UnloadRepositoryImpl(dataSource: ref.read(unloadDataSourceProvider)),
    AppFlavor.dev || AppFlavor.prod => UnloadRepositoryImpl(dataSource: ref.read(unloadDataSourceProvider)),
  };
});

final assignmentRepositoryProvider = Provider<IAssignmentRepository>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => AssignmentRepositoryImpl(
      dataSource: ref.read(assignmentRemoteDataSourceProvider),
      medicineAssignmentMapper: MedicineAssignmentMapper(),
      patientAssignmentMapper: PatientAssignmentMapper(),
    ),
    AppFlavor.dev || AppFlavor.prod => AssignmentRepositoryImpl(
      dataSource: ref.read(assignmentRemoteDataSourceProvider),
      medicineAssignmentMapper: MedicineAssignmentMapper(),
      patientAssignmentMapper: PatientAssignmentMapper(),
    ),
  };
});
