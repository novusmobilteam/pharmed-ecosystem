import '../../../../core/core.dart';

import '../entity/filling_object.dart';
import '../repository/i_filling_list_repository.dart';

class GetRefillCandidatesParams {
  final FillingType type;
  final int stationId;

  GetRefillCandidatesParams({required this.type, required this.stationId});
}

class GetRefillCandidatesUseCase implements UseCase<List<FillingObject>, GetRefillCandidatesParams> {
  final IFillingListRepository _repository;

  GetRefillCandidatesUseCase(this._repository);

  @override
  Future<Result<List<FillingObject>>> call(GetRefillCandidatesParams params) async {
    final type = params.type;
    final stationId = params.stationId;
    final response = await _repository.getRefillCandidates(type: type, stationId: stationId);
    return response.when(
      error: Result.error,
      ok: (data) {
        final objects = data
            .map((d) => FillingObject(quantity: d.quantity ?? 0, medicine: d.medicine, assignment: d.assignment))
            .toList();

        return Result.ok(objects);
      },
    );
  }
}
