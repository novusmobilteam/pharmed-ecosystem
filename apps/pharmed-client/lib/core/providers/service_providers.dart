import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../flavor/app_flavor.dart';
import 'providers.dart';

final serviceRemoteDataSourceProvider = Provider<ServiceRemoteDataSource>((ref) {
  return ServiceRemoteDataSource(apiManager: ref.read(apiManagerProvider));
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
  return result.when(ok: (rooms) => rooms ?? [], error: (e) => throw e);
});

final allBedsProvider = FutureProvider<List<Bed>>((ref) async {
  final useCase = ref.read(_getAllBedsUseCaseProvider);
  final result = await useCase.call();
  return result.when(ok: (beds) => beds ?? [], error: (e) => throw e);
});
