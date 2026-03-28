import '../../../../core/core.dart';
import '../entity/service.dart';

abstract class IServiceRepository {
  Future<Result<ApiResponse<List<HospitalService>>>> getServices({
    int? skip,
    int? take,
    String? search,
  });
  Future<Result<void>> createService(HospitalService service);
  Future<Result<void>> updateService(HospitalService service);
  Future<Result<void>> deleteService(HospitalService service);
}
