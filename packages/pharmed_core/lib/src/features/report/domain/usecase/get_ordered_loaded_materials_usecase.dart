// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Order Edilmiş / Yüklü Malzeme raporunu getirir.
/// İstasyon filtresi `params.filters` içinde `stationId` inList olarak gönderilir.
class GetOrderedLoadedMaterialsUseCase {
  final IReportRepository _repository;

  GetOrderedLoadedMaterialsUseCase(this._repository);

  Future<Result<ApiResponse<List<OrderedLoadedMaterial>>?>> call(PagedQueryParams params) =>
      _repository.getOrderedLoadedMaterials(params: params.copyWith(searchFields: ['barcode', 'materialName']));
}
