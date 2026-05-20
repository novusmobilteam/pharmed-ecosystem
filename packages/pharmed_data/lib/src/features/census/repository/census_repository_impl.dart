import 'package:pharmed_core/pharmed_core.dart';

import '../census.dart';

class CensusRepositoryImpl implements ICensusRepository {
  final CensusRemoteDataSource _dataSource;

  CensusRepositoryImpl({required CensusRemoteDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<Result<void>> masterCensus(List<dynamic> data) async {
    return _dataSource.masterCensus(data);
  }

  @override
  Future<Result<void>> mobileCensus(List<dynamic> data) async {
    return _dataSource.mobileCensus(data);
  }
}
