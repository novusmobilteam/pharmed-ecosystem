import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'providers.dart';

final getHospitalizationsUseCaseProvider = Provider<GetHospitalizationsUseCase>((ref) {
  return GetHospitalizationsUseCase(ref.read(hospitalizationRepositoryProvider));
});

final getDrugsUseCaseProvider = Provider<GetDrugsUseCase>((ref) {
  return GetDrugsUseCase(ref.read(medicineRepositoryProvider));
});

// GetStationUseCase
final getStationUseCaseProvider = Provider<GetStationUseCase>((ref) {
  return GetStationUseCase(ref.read(stationRepositoryProvider));
});

final getServiceUseCaseProvider = Provider<GetServiceUseCase>((ref) {
  return GetServiceUseCase(ref.read(serviceRepositoryProvider));
});

final _getAllServicesUseCaseProvider = Provider<GetAllServicesUseCase>((ref) {
  return GetAllServicesUseCase(ref.read(serviceRepositoryProvider));
});

final _getAllRoomsUseCaseProvider = Provider<GetAllRoomsUseCase>((ref) {
  return GetAllRoomsUseCase(ref.read(serviceRepositoryProvider));
});

final _getAllBedsUseCaseProvider = Provider<GetAllBedsUseCase>((ref) {
  return GetAllBedsUseCase(ref.read(serviceRepositoryProvider));
});

final allServicesProvider = FutureProvider<List<HospitalService>>((ref) async {
  final useCase = ref.read(_getAllServicesUseCaseProvider);
  final result = await useCase.call();
  return result.when(ok: (services) => services ?? [], error: (e) => throw e);
});

final allRoomsProvider = FutureProvider<List<Room>>((ref) async {
  final useCase = ref.read(_getAllRoomsUseCaseProvider);
  final result = await useCase.call();
  return result.when(ok: (rooms) => rooms ?? [], error: (_) => []);
});

final allBedsProvider = FutureProvider<List<Bed>>((ref) async {
  final useCase = ref.read(_getAllBedsUseCaseProvider);
  final result = await useCase.call();
  return result.when(ok: (beds) => beds ?? [], error: (_) => []);
});

// GetCriticalStocksUseCase
final getCriticalStocksUseCaseProvider = Provider<GetCriticalStocksUseCase>((ref) {
  return GetCriticalStocksUseCase(ref.read(dashboardRepositoryProvider));
});

// GetExpiringMaterialsUseCase
final getExpiringMaterialsUseCaseProvider = Provider<GetExpiringMaterialsUseCase>((ref) {
  return GetExpiringMaterialsUseCase(ref.read(dashboardRepositoryProvider));
});

// GetUpcomingTreatmensUseCase
final getUpcomingTreatmensUseCaseProvider = Provider<GetUpcomingTreatmensUseCase>((ref) {
  return GetUpcomingTreatmensUseCase(ref.read(dashboardRepositoryProvider));
});

final getFilteredMenusUseCaseProvider = Provider<GetFilteredMenusUseCase>((ref) {
  return GetFilteredMenusUseCase(ref.read(dashboardRepositoryProvider), isManager: false);
});
