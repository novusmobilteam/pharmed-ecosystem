import '../../../../core/core.dart';

import '../entity/filling_detail.dart';
import '../entity/filling_object.dart';
import '../repository/i_filling_list_repository.dart';

class GetFillingListDetailUseCase implements UseCase<List<FillingObject>, int> {
  final IFillingListRepository _repository;

  GetFillingListDetailUseCase(this._repository);

  @override
  Future<Result<List<FillingObject>>> call(int fillingListId) async {
    final response = await _repository.getFillingListDetail(fillingListId);
    return response.when(
      error: Result.error,
      ok: (data) {
        final Map<int, List<FillingDetail>> grouped = {};
        for (final d in data) {
          final key = d.medicineId ?? 0;
          grouped.putIfAbsent(key, () => []).add(d);
        }

        final objects = grouped.entries.map((entry) {
          final details = entry.value;
          final firstDetail = details.first;

          final totalQuantity = details.fold<num>(0, (sum, d) => sum + (d.quantity ?? 0));

          return FillingObject(
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
