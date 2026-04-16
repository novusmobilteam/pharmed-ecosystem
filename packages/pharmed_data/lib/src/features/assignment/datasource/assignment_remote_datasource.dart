import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/network/base_remote_datasource.dart';

// [SWREQ-DATA-ASSIGNMENT-001]
// Sınıf: Class B
class AssignmentRemoteDataSource extends BaseRemoteDataSource {
  AssignmentRemoteDataSource({required super.apiManager});

  static const _base = '/CabinDrawrQuantity';

  String get logSwreq => 'SWREQ-DATA-ASSIGNMENT-001';

  String get logUnit => 'SW-UNIT-ASSIGNMENT';

  /// Belirtilen kabindeki tüm ilaç atamalarını getirir.
  Future<Result<List<MedicineAssignmentDto>>> getMedicineAssignments(int cabinId) async {
    final res = await fetchRequest<List<MedicineAssignmentDto>>(
      path: '$_base/cabin/$cabinId',
      parser: BaseRemoteDataSource.listParser(MedicineAssignmentDto.fromJson),
      successLog: 'Atamalar getirildi',
      emptyLog: 'Atama bulunamadı',
    );

    return res.when(ok: (list) => Result.ok(list ?? const <MedicineAssignmentDto>[]), error: Result.error);
  }

  /// Bir çekmece gözüne yeni ilaç ataması oluşturur.
  Future<Result<void>> createMedicineAssignment(MedicineAssignmentDto dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Atama oluşturuldu',
    );
  }

  /// Mevcut bir ilaç atamasını günceller.
  Future<Result<void>> updateMedicineAssignment(MedicineAssignmentDto dto) {
    return updateRequest(
      path: '$_base/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Quantity updated',
    );
  }

  /// Belirtilen ID'ye sahip ilaç atamasını siler.
  Future<Result<void>> deleteMedicineAssignment(int id) {
    return deleteRequest<void>(
      path: '$_base/cabinDrawr/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Quantity deleted',
    );
  }

  /// Belirtilen ilaca ait tüm kabin atamalarını getirir.
  Future<Result<List<MedicineAssignmentDto>>> getMaterialAssignment(int materialId) async {
    final res = await fetchRequest<List<MedicineAssignmentDto>>(
      path: '$_base/openCabinForMaterial/$materialId',
      parser: BaseRemoteDataSource.listParser(MedicineAssignmentDto.fromJson),
      successLog: 'Material Quantity fetched',
      emptyLog: 'No Quantity',
    );

    return res.when(ok: (list) => Result.ok(list ?? const <MedicineAssignmentDto>[]), error: Result.error);
  }

  /// Giriş yapılan kabine ataması yapılmış ilaçları getirir.
  Future<Result<List<MedicineAssignmentDto>>> getCabinAssignments() async {
    final res = await fetchRequest<List<MedicineAssignmentDto>>(
      path: '$_base/cabinInMaterials',
      parser: BaseRemoteDataSource.listParser(MedicineAssignmentDto.fromJson),
      successLog: 'Cabin Materials fetched',
      emptyLog: 'No material',
      envelope: ResponseEnvelope.auto,
    );

    return res.when(ok: (list) => Result.ok(list ?? const <MedicineAssignmentDto>[]), error: Result.error);
  }

  /// Belirtilen kabine ataması yapılmış ilaçları getirir.
  Future<Result<List<MedicineAssignmentDto>>> getCabinAssignmentsWithCabinId(int cabinId) async {
    final res = await fetchRequest<List<MedicineAssignmentDto>>(
      path: '$_base/cabinInMaterials/$cabinId',
      parser: BaseRemoteDataSource.listParser(MedicineAssignmentDto.fromJson),
      successLog: 'Cabin Materials fetched',
      emptyLog: 'No material',
      envelope: ResponseEnvelope.auto,
    );

    return res.when(ok: (list) => Result.ok(list ?? const <MedicineAssignmentDto>[]), error: Result.error);
  }

  /// Bağımsız (reçetesiz) malzemeleri getirir.
  Future<Result<List<MedicineAssignmentDto>>> getIndependentMaterials() async {
    final res = await fetchRequest<List<MedicineAssignmentDto>>(
      path: '$_base/cabinInMaterialsIndependent',
      parser: BaseRemoteDataSource.listParser(MedicineAssignmentDto.fromJson),
    );

    return res.when(ok: (list) => Result.ok(list ?? const <MedicineAssignmentDto>[]), error: Result.error);
  }

  /// Giriş yapmış kullanıcının ordersız alım yapabileceği ilaçları getirir.
  Future<Result<List<MedicineAssignmentDto>>> getOrderlessCabinAssignments() async {
    final res = await fetchRequest<List<MedicineAssignmentDto>>(
      path: '$_base/cabinInMaterialsOrderless',
      parser: BaseRemoteDataSource.listParser(MedicineAssignmentDto.fromJson),
    );

    return res.when(ok: (list) => Result.ok(list ?? const <MedicineAssignmentDto>[]), error: Result.error);
  }

  /// Mobil kabin gözüne yatak ataması yapar.
  Future<Result<void>> createPatientAssignment({required int cellId, required int bedId}) {
    print({"cabinDrawrDetailId": cellId, "bedId": bedId});
    return createRequest(
      path: '/CabinMobileDrawrQuantity',
      body: {"cabinDrawrDetailId": cellId, "bedId": bedId},
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Atama oluşturuldu',
    );
  }

  /// Belirtilen kabindeki tüm hasta atamalarını getirir.
  Future<Result<List<PatientAssignmentDto>>> getPatientAssignments(int cabinId) async {
    final res = await fetchRequest<List<PatientAssignmentDto>>(
      path: '/CabinMobileDrawrQuantity/cabin/$cabinId',
      parser: BaseRemoteDataSource.listParser(PatientAssignmentDto.fromJson),
      successLog: 'Atamalar getirildi',
      emptyLog: 'Atama bulunamadı',
    );

    return res.when(ok: (list) => Result.ok(list ?? const <PatientAssignmentDto>[]), error: Result.error);
  }
}
