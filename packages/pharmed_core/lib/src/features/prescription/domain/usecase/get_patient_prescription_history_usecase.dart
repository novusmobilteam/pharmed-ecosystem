import 'package:pharmed_core/pharmed_core.dart';

class GetPatientPrescriptionHistoryUseCase {
  final IPrescriptionRepository _repository;

  GetPatientPrescriptionHistoryUseCase(this._repository);

  Future<Result<List<PrescriptionItem>>> call(int patientId, {PagedQueryParams? params}) async {
    final result = await _repository.getPatientPrescriptionHistory(
      patientId,
      skip: params?.skip,
      take: params?.take,
      searchQuery: params?.searchQuery,
      startDate: params?.startDate,
      endDate: params?.endDate,
      filters: params?.filters,
    );
    return result.when(
      error: Result.error,
      ok: (response) {
        final items = response?.data ?? [];
        final sorted = [...items]
          ..sort((a, b) {
            // 1. İlaç adına göre
            final nameA = a.medicine?.name ?? '';
            final nameB = b.medicine?.name ?? '';
            final nameCompare = nameA.compareTo(nameB);
            if (nameCompare != 0) return nameCompare;

            // 2. Aynı ilaçsa time'a göre
            if (a.time == null && b.time == null) return 0;
            if (a.time == null) return 1;
            if (b.time == null) return -1;
            return a.time!.compareTo(b.time!);
          });
        return Result.ok(sorted);
      },
    );
  }
}
