import '../../../../core/core.dart';
import '../model/medicine_dto.dart';
import 'medicine_datasource.dart';

class _MedicineStore extends BaseLocalDataSource<MedicineDTO, int> {
  _MedicineStore({required super.filePath})
      : super(
          fromJson: (m) => MedicineDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) {
            if (d is DrugDTO) return d.id ?? -1;
            if (d is MedicalConsumableDTO) return d.id ?? -1;
            return -1;
          },
          assignId: (d, id) => MedicineDTO.fromJson({...d.toJson(), 'id': id}),
        );
}

class MedicineLocalDataSource implements MedicineDataSource {
  final _MedicineStore _medicineStore;

  MedicineLocalDataSource({
    required String assetPath,
  }) : _medicineStore = _MedicineStore(filePath: assetPath);

  @override
  Future<Result<ApiResponse<List<MedicineDTO>>>> getMedicines({
    int? skip,
    int? take,
    String? search,
  }) {
    return _medicineStore.fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
    );
  }

  @override
  Future<Result<ApiResponse<List<DrugDTO>>>> getDrugs({int? skip, int? take, String? search}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<ApiResponse<List<MedicalConsumableDTO>>>> getMedicalConsumables({
    int? skip,
    int? take,
    String? search,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<ApiResponse<List<MedicineDTO>>>> getEquivalentMedicines(
    int medicineId, {
    int? skip,
    int? take,
    String? search,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> createMedicine(MedicineDTO medicine) async {
    return Result.ok(null);
  }

  @override
  Future<Result<void>> deleteMedicine(MedicineDTO medicine) async {
    return Result.ok(null);
  }

  @override
  Future<Result<void>> updateMedicine(MedicineDTO medicine) async {
    return Result.ok(null);
  }

  @override
  Future<Result<DrugDTO?>> getDrug(int id) async {
    return Result.ok(null);
  }
}
