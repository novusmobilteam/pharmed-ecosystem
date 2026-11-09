// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// SKT Malzeme Listesi — istasyondaki stokların son kullanma tarihine kalan
/// süreyle listesi (`Report/remainingMiadDate/{stationId}`). Tarih filtresi
/// `miadDate` alanına DevExtreme filtresiyle uygulanır.
class GetExpiryDateStocksUseCase {
  final IReportRepository _repository;

  GetExpiryDateStocksUseCase(this._repository);

  Future<Result<ApiResponse<List<CabinStock>>?>> call(PagedQueryParams params, {required int stationId}) =>
      _repository.getExpiryDateStocks(
        stationId: stationId,
        params: params.copyWith(
          searchFields: ['material.barcode', 'material.code', 'material.name', 'shelfNo', 'quantity'],
        ),
      );
}
