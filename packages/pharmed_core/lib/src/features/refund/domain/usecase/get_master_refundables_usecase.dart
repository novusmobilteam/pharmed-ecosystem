import 'package:pharmed_core/pharmed_core.dart';

class GetMasterRefundablesUseCase {
  final IRefundRepository _repository;

  GetMasterRefundablesUseCase(this._repository);

  Future<Result<List<CabinTargetedPrescriptionItem>>> call(int hospitalizationId) async {
    final result = await _repository.getMasterRefundables(hospitalizationId: hospitalizationId);

    return result.when(
      ok: (items) {
        final sorted = List<CabinTargetedPrescriptionItem>.from(items)
          ..sort((a, b) {
            final aTime = a.time;
            final bTime = b.time;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });
        return Result.ok(sorted);
      },
      error: (e) => Result.error(e),
    );
  }
}
