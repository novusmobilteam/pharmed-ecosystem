import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-MEDICINE-001]
// Sınıf: Class B
class MedicineRemoteDataSource extends BaseRemoteDataSource {
  MedicineRemoteDataSource({required super.apiManager});

  static const _base = '/Material';

  @override
  String get logSwreq => 'SWREQ-DATA-MEDICINE-001';

  @override
  String get logUnit => 'SW-UNIT-MEDICINE';

  Future<Result<ApiResponse<List<MedicineDto>>?>> getMedicines({int? skip, int? take, String? searchQuery}) async {
    return fetchRequest(
      path: '$_base/all',
      skip: skip,
      take: take,
      searchQuery: searchQuery,
      searchFields: const ['name', 'barcode', 'atcCode'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(MedicineDto.fromJson),
      successLog: 'Malzemeler getirildi',
      emptyLog: 'Malzeme bulunamadı',
    );
  }

  Future<Result<ApiResponse<List<DrugDTO>>?>> getDrugs({int? skip, int? take, String? search}) async {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchQuery: search,
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
      searchQuery: search,
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
      searchQuery: search,
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

  Future<Result<void>> createMedicine(MedicineDto dto) {
    final path = dto.when(drug: (_) => '/Material', consumable: (_) => '/MedicalConsumables');

    return postRequest(
      path: path,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Malzeme oluşturuldu',
    );
  }

  Future<Result<void>> updateMedicine(MedicineDto dto) {
    final path = dto.when(drug: (d) => '/Material/${d.id}', consumable: (c) => '/MedicalConsumables/${c.id}');

    return putRequest(
      path: path,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Malzeme güncellendi',
    );
  }

  Future<Result<void>> deleteMedicine(MedicineDto dto) {
    final path = dto.when(drug: (d) => '/Material/${d.id}', consumable: (c) => '/MedicalConsumables/${c.id}');
    return deleteRequest(path: path, parser: BaseRemoteDataSource.voidParser(), successLog: 'Malzeme tipi silindi');
  }
}
