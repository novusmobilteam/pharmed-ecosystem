import 'package:pharmed_core/pharmed_core.dart';

import '../unload.dart';

class UnloadRepositoryImpl implements IUnloadRepository {
  final UnloadRemoteDataSource _dataSource;

  UnloadRepositoryImpl({required UnloadRemoteDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<Result<void>> masterUnload(List<Map<String, dynamic>> data) async {
    return _dataSource.masterUnload(data);
  }

  @override
  Future<Result<void>> mobileUnload(List<Map<String, dynamic>> data) async {
    return _dataSource.mobileUnload(data);
  }

  @override
  Future<Result<void>> reportMissingStock(int prescriptionItemId) {
    return _dataSource.reportMissingStock(prescriptionItemId);
  }
}
