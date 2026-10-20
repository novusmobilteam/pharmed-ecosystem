// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Hareketsiz Malzeme raporunu getirir.
/// İstasyon filtresi `params.filters` içinde `stationId` inList olarak gönderilir.
class GetInertMaterialsUseCase {
  final IReportRepository _repository;

  GetInertMaterialsUseCase(this._repository);

  Future<Result<ApiResponse<List<InertMaterial>>?>> call(PagedQueryParams params) =>
      _repository.getInertMaterials(params: params.copyWith(searchFields: ['barcode', 'materialName']));
}
