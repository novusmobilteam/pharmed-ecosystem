import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class CensusRemoteDataSource extends BaseRemoteDataSource {
  CensusRemoteDataSource({required super.apiManager});

  static const _base = '/CabinDrawrStock';

  @override
  String get logSwreq => 'SWREQ-DATA-CENSUS-001';

  @override
  String get logUnit => 'SW-UNIT-CENSUS';

  /// Master kabin sayım işlemi
  Future<Result<void>> masterCensus(List<dynamic> data) async {
    return await putRequest(
      path: '$_base/censusQuantity',
      parser: BaseRemoteDataSource.voidParser(),
      body: data.map((e) => e.toJson()).toList(),
      successLog: 'Census quantity updated',
    );
  }

  /// Mobil kabin sayım işlemi
  Future<Result<void>> mobileCensus(List<dynamic> data) async {
    return await putRequest(
      path: '$_base/censusQuantityMobile',
      parser: BaseRemoteDataSource.voidParser(),
      body: data.map((e) => e.toJson()).toList(),
      successLog: 'Census quantity updated',
    );
  }
}
