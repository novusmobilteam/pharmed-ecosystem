import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class UnloadRemoteDataSource extends BaseRemoteDataSource {
  UnloadRemoteDataSource({required super.apiManager});

  static const _base = '/CabinDrawrStock';

  @override
  String get logSwreq => 'SWREQ-DATA-UNLOAD-001';

  @override
  String get logUnit => 'SW-UNIT-UNLOAD';

  Future<Result<void>> masterUnload(List<Map<String, dynamic>> data) async {
    return await postRequest(
      path: '$_base/emptying',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
      successLog: 'Unload process completed',
    );
  }

  Future<Result<void>> mobileUnload(List<Map<String, dynamic>> data) async {
    return await postRequest(
      path: '$_base/emptyingMobile',
      parser: BaseRemoteDataSource.voidParser(),
      body: data,
      successLog: 'Unload process completed',
    );
  }

  Future<Result<List<ReturnDrawerMedicineDTO>?>> getReturnDrawerMedicines() async {
    return await fetchRequest(
      path: '/ReturnDrawerMaterial',
      parser: BaseRemoteDataSource.listParser(ReturnDrawerMedicineDTO.fromJson),
    );
  }

  Future<Result<void>> unloadReturnDrawer(List<int> medicineIds) async {
    return await postRequest(
      path: '/ReturnDrawerMaterial/empty',
      parser: BaseRemoteDataSource.voidParser(),
      body: {"returnDrawerMaterialIds": medicineIds},
      successLog: 'Unload process completed',
    );
  }

  Future<Result<List<ReturnDrawerMedicineDTO>?>> getReturnBoxMedicines() async {
    return await fetchRequest(
      path: '/ReturnBoxMaterial',
      parser: BaseRemoteDataSource.listParser(ReturnDrawerMedicineDTO.fromJson),
    );
  }

  Future<Result<void>> unloadReturnBox(List<int> medicineIds) async {
    return await postRequest(
      path: '/ReturnBoxMaterial/empty',
      parser: BaseRemoteDataSource.voidParser(),
      body: {"returnBoxMaterialIds": medicineIds},
      successLog: 'Unload process completed',
    );
  }
}
