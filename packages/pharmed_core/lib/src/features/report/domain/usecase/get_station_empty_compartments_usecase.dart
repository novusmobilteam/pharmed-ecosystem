// [SWREQ-CORE-STOCK-UC-004]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// İstasyon Boş Göz Listesi — çekmece bazında özet.
/// İstasyon filtresi `params.filters` içinde `stationId` inList olarak gönderilir.
class GetStationEmptyCompartmentsUseCase {
  final IReportRepository _repository;

  GetStationEmptyCompartmentsUseCase(this._repository);

  Future<Result<ApiResponse<List<StationEmptyCompartment>>?>> call(PagedQueryParams params) =>
      _repository.getStationEmptyCompartments(
        params: params.copyWith(searchFields: ['stationName', 'cabinName', 'drawrName']),
      );
}

/// İstasyon Boş Göz Listesi — seçilen çekmecenin (cabinDesignId) boş göz detayları.
class GetStationEmptyCompartmentDetailsUseCase {
  final IReportRepository _repository;

  GetStationEmptyCompartmentDetailsUseCase(this._repository);

  Future<Result<List<StationEmptyCompartmentDetail>>> call(int cabinDesignId) =>
      _repository.getStationEmptyCompartmentDetails(cabinDesignId);
}
