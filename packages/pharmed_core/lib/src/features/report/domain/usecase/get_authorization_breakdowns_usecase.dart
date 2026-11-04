// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Yetki Kırım raporunu getirir (ordersız / serbest erişimli alımlar).
/// İstasyon ve tarih aralığı servise query parametresi olarak gönderilir.
class GetAuthorizationBreakdownsUseCase {
  final IReportRepository _repository;

  GetAuthorizationBreakdownsUseCase(this._repository);

  Future<Result<ApiResponse<List<AuthorizationBreakdown>>?>> call(PagedQueryParams params, {required int stationId}) =>
      _repository.getAuthorizationBreakdowns(
        stationId: stationId,
        params: params.copyWith(searchFields: ['patientFullName', 'materialName', 'userFullName']),
      );
}
