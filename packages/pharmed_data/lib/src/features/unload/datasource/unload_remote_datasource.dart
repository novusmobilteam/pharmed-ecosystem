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
}
