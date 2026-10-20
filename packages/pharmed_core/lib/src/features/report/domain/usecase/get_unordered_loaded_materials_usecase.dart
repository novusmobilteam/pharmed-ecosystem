// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Order Edilmemiş / Yüklü Malzeme raporunu getirir.
/// İstasyon filtresi `params.filters` içinde `stationId` inList olarak gönderilir.
class GetUnorderedLoadedMaterialsUseCase {
  final IReportRepository _repository;

  GetUnorderedLoadedMaterialsUseCase(this._repository);

  Future<Result<ApiResponse<List<UnorderedLoadedMaterial>>?>> call(PagedQueryParams params) =>
      _repository.getUnorderedLoadedMaterials(params: params.copyWith(searchFields: ['barcode', 'materialName']));
}
