import '../../../../core/core.dart';

import '../../../medicine/domain/entity/medicine.dart';
import '../../../medicine/domain/repository/i_medicine_repository.dart';
import '../../../medicine_management/domain/entity/cabin_operation_item.dart';
import '../../../medicine_management/domain/repository/i_medicine_management_repository.dart';
import '../../../prescription/domain/entity/prescription_item.dart';
import '../../../station/domain/entity/station.dart';
import '../mapper/prescription_item_mapper.dart';

class GetDisposablesUseCase implements UseCase<List<CabinOperationItem>, int> {
  final IMedicineManagementRepository _repository;
  final IMedicineRepository _medicineRepository;

  GetDisposablesUseCase(this._repository, this._medicineRepository);

  @override
  Future<Result<List<CabinOperationItem>>> call(int hospitalizationId) async {
    final result = await _repository.getDisposables(hospitalizationId: hospitalizationId);

    return result.when(
      ok: (items) async {
        final List<CabinOperationItem> mapped = [];

        for (final item in items) {
          var (witnesses, stations) = await _fetchWitnesses(item);
          mapped.add(item.toCabinOperationItem(witnesses: witnesses, stations: stations));
        }

        return Result.ok(mapped);
      },
      error: Result.error,
    );
  }

  /// İlacın şahitli imha gerektirip gerektirmediğini kontrol eder.
  /// Gerektiriyorsa şahit kullanıcı ve istasyon listesini çeker.
  Future<(List<User>, List<Station>)> _fetchWitnesses(PrescriptionItem item) async {
    final medicine = item.medicine;
    if (medicine == null || medicine is! Drug) return (<User>[], <Station>[]);

    final drug = medicine;
    if (!drug.isWastageWitnessedPurchase) return (<User>[], <Station>[]);

    List<User> witnesses = [];
    List<Station> stations = [];

    final res = await _medicineRepository.getDrug(medicine.id ?? 0);
    res.when(
      error: (_) {},
      ok: (data) {
        witnesses = data?.wastageWitnessedPurchaseUsers ?? [];
        stations = data?.witnessedPurchaseStations ?? [];
      },
    );

    return (witnesses, stations);
  }
}
