import '../../../../core/core.dart';

import '../../../station/domain/repository/i_station_repository.dart';
import '../entity/cabin.dart';
import '../repository/i_cabin_repository.dart';

class CreateCabinUseCase implements UseCase<void, Cabin> {
  final ICabinRepository _repository;
  final IStationRepository _stationRepository;

  CreateCabinUseCase(this._repository, this._stationRepository);

  @override
  Future<Result<void>> call(Cabin cabin) async {
    final stationId = cabin.station?.id;
    if (stationId == null) {
      return Result.error(
        ServiceException(
          message: 'Kabin oluşturma işlemi sırasında bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.',
          statusCode: 404,
        ),
      );
    }
    final res = await _stationRepository.updateStationMacAddress(stationId);
    return res.when(error: Result.error, ok: (_) => _repository.createCabin(cabin));
  }
}
