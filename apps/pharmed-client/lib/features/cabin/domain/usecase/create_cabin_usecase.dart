// [SWREQ-CORE-CABIN-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class CreateCabinUseCase {
  final ICabinRepository _repository;
  final IStationRepository _stationRepository;

  CreateCabinUseCase(this._repository, this._stationRepository);

  Future<Result<Cabin?>> call(Cabin cabin) async {
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
