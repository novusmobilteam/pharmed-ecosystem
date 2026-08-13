import 'package:pharmed_core/pharmed_core.dart';

class GetRefillCandidatesParams {
  final RefillType type;
  final int stationId;

  GetRefillCandidatesParams({required this.type, required this.stationId});
}

class GetRefillCandidatesUseCase {
  final IRefillListRepository _repository;

  GetRefillCandidatesUseCase(this._repository);

  Future<Result<List<RefillObject>>> call(GetRefillCandidatesParams params) async {
    final type = params.type;
    final stationId = params.stationId;
    final response = await _repository.getRefillCandidates(type: type, stationId: stationId);
    return response.when(
      error: Result.error,
      ok: (data) {
        final objects = data
            .map((d) => RefillObject(quantity: d.quantity ?? 0, medicine: d.medicine, assignment: d.assignment))
            .toList();

        return Result.ok(objects);
      },
    );
  }
}
