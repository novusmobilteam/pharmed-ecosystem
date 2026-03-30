import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_data/src/network/base_remote_datasource.dart';

// [SWREQ-DATA-MEDICINE-001]
// Sınıf: Class B
class MedicineRemoteDataSource extends BaseRemoteDataSource {
  MedicineRemoteDataSource({required super.apiManager});

  static const _base = '/Material';

  @override
  String get logSwreq => 'SWREQ-DATA-MEDICINE-001';

  @override
  String get logUnit => 'SW-UNIT-MEDICINE';

  Future<Result<ApiResponse<List<MedicineDTO>>?>> getMedicines({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: '$_base/all',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(MedicineDTO.fromJson),
      successLog: 'Malzemeler getirildi',
      emptyLog: 'Malzeme bulunamadı',
    );
  }

  Future<Result<ApiResponse<List<DrugDTO>>?>> getDrugs({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(DrugDTO.fromJson),
      successLog: 'İlaçlar getirildi',
      emptyLog: 'İlaç bulunamadı',
    );
  }

  Future<Result<ApiResponse<List<MedicalConsumableDTO>>?>> getMedicalConsumables({
    int? skip,
    int? take,
    String? search,
  }) async {
    return fetchRequest(
      path: '/MedicalConsumables',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(MedicalConsumableDTO.fromJson),
      successLog: 'Tıbbi sarflar getirildi',
      emptyLog: 'Tıbbi sarf bulunamadı',
    );
  }

  Future<Result<ApiResponse<List<DrugDTO>>?>> getEquivalentMedicines(
    int medicineId, {
    int? skip,
    int? take,
    String? search,
  }) async {
    return fetchRequest(
      path: '$_base/equivalentMaterials/$medicineId',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(DrugDTO.fromJson),
      successLog: 'İlaçlar getirildi',
      emptyLog: 'İlaç bulunamadı',
    );
  }

  Future<Result<DrugDTO?>> getDrug(int id) {
    return fetchRequest(
      path: '$_base/$id',
      parser: BaseRemoteDataSource.singleParser(DrugDTO.fromJson),
      successLog: 'İlaç getirildi',
    );
  }

  Future<Result<void>> createMedicine(MedicineDTO dto) {
    final path = dto.when(drug: (_) => '/Material', consumable: (_) => '/MedicalConsumables');

    return createRequest(
      path: path,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Malzeme oluşturuldu',
    );
  }

  Future<Result<void>> updateMedicine(MedicineDTO dto) {
    final path = dto.when(drug: (d) => '/Material/${d.id}', consumable: (c) => '/MedicalConsumables/${c.id}');

    return updateRequest(
      path: path,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Malzeme güncellendi',
    );
  }

  Future<Result<void>> deleteMedicine(MedicineDTO dto) {
    final path = dto.when(drug: (d) => '/Material/${d.id}', consumable: (c) => '/MedicalConsumables/${c.id}');
    return deleteRequest(path: path, parser: BaseRemoteDataSource.voidParser(), successLog: 'Malzeme tipi silindi');
  }
}
