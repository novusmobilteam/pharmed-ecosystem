// [SWREQ-CORE-CABIN-UC-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class CreateCabinUseCase {
  final ICabinRepository _repository;
  final IStationRepository _stationRepository;

  CreateCabinUseCase(this._repository, this._stationRepository);

  Future<Result<Cabin?>> call(Cabin cabin) async {
    final stationId = cabin.station?.id;
    if (stationId == null) {
      return Result.error(
        ServiceException(
          message: contextlessL10n().cabinCore_createError,
          statusCode: 404,
        ),
      );
    }
    final res = await _stationRepository.updateStationMacAddress(stationId);
    return res.when(
      error: Result.error,
      ok: (_) => _repository.createCabin(cabin.copyWith(status: Status.active)),
    );
  }
}
