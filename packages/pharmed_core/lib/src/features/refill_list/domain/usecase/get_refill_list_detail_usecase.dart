import 'package:pharmed_core/pharmed_core.dart';

class GetRefillListDetailUseCase {
  final IRefillListRepository _repository;

  GetRefillListDetailUseCase(this._repository);

  Future<Result<List<RefillObject>>> call(int fillingListId) async {
    final response = await _repository.getFillingListDetail(fillingListId);
    return response.when(
      error: Result.error,
      ok: (data) {
        final Map<int, List<RefillListDetail>> grouped = {};
        for (final d in data) {
          final key = d.medicineId ?? 0;
          grouped.putIfAbsent(key, () => []).add(d);
        }

        final objects = grouped.entries.map((entry) {
          final details = entry.value;
          final firstDetail = details.first;

          final totalQuantity = details.fold<num>(0, (sum, d) => sum + (d.quantity ?? 0));

          return RefillObject(
            detailIds: details.map((d) => d.id ?? 0).toList(),
            medicine: firstDetail.medicine,
            assignment: firstDetail.cabinAssignment,
            quantity: totalQuantity,
            canEdit: firstDetail.isEdit ?? false,
            stocks: details.expand((d) => d.stocks ?? <CabinStock>[]).toList(),
          );
        }).toList();

        return Result.ok(objects);
      },
    );
  }
}
