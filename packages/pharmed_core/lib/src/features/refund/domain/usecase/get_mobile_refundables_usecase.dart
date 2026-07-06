import 'package:pharmed_core/pharmed_core.dart';

class GetMobileRefundablesUseCase {
  final IRefundRepository _repository;

  GetMobileRefundablesUseCase(this._repository);

  Future<Result<List<PrescriptionItem>>> call(int hospitalizationId) async {
    final result = await _repository.getMobileRefundables(hospitalizationId: hospitalizationId);

    return result.when(
      ok: (items) {
        final sorted = [...items]
          ..sort((a, b) {
            final aDate = a.lastMovement?.createdAt;
            final bDate = b.lastMovement?.createdAt;
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });
        return Result.ok(sorted);
      },
      error: Result.error,
    );
  }
}
