// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Order Edilmiş / Yüklenmemiş Malzeme raporunu getirir.
/// İstasyon filtresi `params.filters` içinde `stationId` inList olarak,
/// tarih aralığı `orderDate` alanı üzerinden gönderilir.
class GetOrderedNotLoadedMaterialsUseCase {
  final IReportRepository _repository;

  GetOrderedNotLoadedMaterialsUseCase(this._repository);

  Future<Result<ApiResponse<List<OrderedNotLoadedMaterial>>?>> call(PagedQueryParams params) =>
      _repository.getOrderedNotLoadedMaterials(
        params: params.copyWith(searchFields: ['barcode', 'materialName', 'patientFullName', 'protocolNo']),
      );
}
