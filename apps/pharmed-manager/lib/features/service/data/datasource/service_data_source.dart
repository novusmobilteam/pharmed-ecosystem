import '../../../../core/core.dart';
import '../model/service_dto.dart';

/// Hastane Servisi işlemleri için veri kaynağı arayüzü.
abstract class ServiceDataSource {
  /// Hastane servislerini sayfalı bir şekilde listeler.
  Future<Result<ApiResponse<List<ServiceDTO>>>> getServices({
    int? skip,
    int? take,
    String? search,
  });

  /// Yeni bir servis oluşturur.
  Future<Result<void>> createService(ServiceDTO service);

  /// Mevcut bir servisi günceller.
  Future<Result<void>> updateService(ServiceDTO service);

  /// ID'si verilen servisi siler.
  Future<Result<void>> deleteService(int id);
}
