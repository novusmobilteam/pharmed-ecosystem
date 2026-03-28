import '../../../../core/core.dart';

import '../model/medicine_dto.dart';
import 'medicine_datasource.dart';

/// İlaç ve Tıbbi Sarf Malzemesi işlemleri için uzak (API) veri kaynağı.
class MedicineRemoteDataSource extends BaseRemoteDataSource implements MedicineDataSource {
  final String _basePath = '/Material';

  MedicineRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<MedicineDTO>>>> getMedicines({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<MedicineDTO>>>(
      path: '$_basePath/all',
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(MedicineDTO.fromJson),
      successLog: 'Materials fetched',
      emptyLog: 'No materials',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<ApiResponse<List<DrugDTO>>>> getDrugs({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest<ApiResponse<List<DrugDTO>>>(
      path: _basePath,
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(DrugDTO.fromJson),
      successLog: 'Drugs fetched',
      emptyLog: 'No drugs',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const ApiResponse(data: [], totalCount: 0)),
      error: Result.error,
    );
  }

  @override
  Future<Result<ApiResponse<List<MedicalConsumableDTO>>>> getMedicalConsumables({
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest(
      path: '/MedicalConsumables',
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(MedicalConsumableDTO.fromJson),
      successLog: 'Medical consumables fetched',
      emptyLog: 'No medical consumables',
    );

    return res.when(
      ok: (data) => Result.ok(
        data ?? const ApiResponse(data: [], totalCount: 0),
      ),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createMedicine(MedicineDTO medicine) {
    final path = medicine.when(
      drug: (_) => '/Material',
      consumable: (_) => '/MedicalConsumables',
    );

    return createRequest<void>(
      path: path,
      body: medicine.toJson(),
      parser: singleParser(MedicineDTO.fromJson),
      successLog: 'Medicine created',
    );
  }

  @override
  Future<Result<void>> updateMedicine(MedicineDTO medicine) {
    final path = medicine.when(
      drug: (d) => '/Material/${d.id}',
      consumable: (c) => '/MedicalConsumables/${c.id}',
    );

    return updateRequest<void>(
      path: path,
      body: medicine.toJson(),
      parser: voidParser(),
      successLog: 'Medicine updated',
    );
  }

  @override
  Future<Result<void>> deleteMedicine(MedicineDTO medicine) {
    final path = medicine.when(
      drug: (d) => '/Material/${d.id}',
      consumable: (c) => '/MedicalConsumables/${c.id}',
    );

    return deleteRequest<void>(
      path: path,
      body: medicine.toJson(),
      parser: voidParser(),
      successLog: 'Medicine deleted',
    );
  }

  @override
  Future<Result<ApiResponse<List<MedicineDTO>>>> getEquivalentMedicines(
    int medicineId, {
    int? skip,
    int? take,
    String? search,
  }) async {
    final res = await fetchRequest(
      path: '$_basePath/equivalentMaterials/$medicineId',
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(MedicineDTO.fromJson),
      successLog: 'Equivalent Medicines fetched',
      emptyLog: 'No Equivalent Medicines',
    );

    return res.when(
      ok: (data) => Result.ok(
        data ?? const ApiResponse(data: [], totalCount: 0),
      ),
      error: Result.error,
    );
  }

  @override
  Future<Result<DrugDTO?>> getDrug(int id) {
    return fetchRequest(
      path: '$_basePath/$id',
      parser: singleParser(DrugDTO.fromJson),
      successLog: 'Drug fetched',
      emptyLog: 'No drug',
    );
  }
}
