import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'providers.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinStockRemoteDataSourceProvider = Provider<CabinStockRemoteDataSource>((ref) {
  return CabinStockRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinStockLocalDataSourceProvider = Provider<CabinStockLocalDataSource>((ref) {
  return CabinStockLocalDataSource();
});

final hospitalizationRemoteDataSourceProvider = Provider<HospitalizationRemoteDataSource>((ref) {
  return HospitalizationRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final medicineRemoteDataSourceProvider = Provider<MedicineRemoteDataSource>((ref) {
  return MedicineRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final prescriptionRemoteDataSourceProvider = Provider<PrescriptionRemoteDataSource>((ref) {
  return PrescriptionRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final stationRemoteDataSourceProvider = Provider<StationRemoteDataSource>((ref) {
  return StationRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final serviceRemoteDataSourceProvider = Provider<ServiceRemoteDataSource>((ref) {
  return ServiceRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final faultRemoteDataSourceProvider = Provider<FaultRemoteDataSource>((ref) {
  return FaultRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final assignmentRemoteDataSourceProvider = Provider<AssignmentRemoteDataSource>((ref) {
  return AssignmentRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinRemoteDataSourceProvider = Provider<CabinRemoteDataSource>((ref) {
  return CabinRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinLocaleDataSourceProvider = Provider<ICabinLocalDataSource>((ref) {
  return CabinLocalDataSource();
});

final intakeDataSourceProvider = Provider((ref) {
  return IntakeRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final refundDataSourceProvider = Provider((ref) {
  return RefundRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final wasteDataSourceProvider = Provider((ref) {
  return WasteRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final patientDataSourceProvider = Provider((ref) {
  return PatientRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final censusDataSourceProvider = Provider((ref) {
  return CensusRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final unloadDataSourceProvider = Provider((ref) {
  return UnloadRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});

final cabinTemperatureDataSourceProvider = Provider((ref) {
  return CabinTemperatureRemoteDataSource(apiManager: ref.read(apiManagerProvider));
});
