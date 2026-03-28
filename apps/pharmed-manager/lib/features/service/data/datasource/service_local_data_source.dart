import '../../../../core/core.dart';
import '../model/service_dto.dart';
import 'service_data_source.dart';

/// Hastane Servisi işlemleri için yerel (Mock) veri kaynağı.
class ServiceLocalDataSource extends BaseLocalDataSource<ServiceDTO, int> implements ServiceDataSource {
  ServiceLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => ServiceDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => ServiceDTO(
            id: id,
            name: d.name,
            branchId: d.branchId,
            branch: d.branch,
            userId: d.userId,
            user: d.user,
            isActive: d.isActive,
          ),
        );

  @override
  Future<Result<ApiResponse<List<ServiceDTO>>>> getServices({
    int? skip,
    int? take,
    String? search,
  }) {
    return fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
    );
  }

  @override
  Future<Result<void>> createService(ServiceDTO dto) => createRequest(dto);

  @override
  Future<Result<void>> updateService(ServiceDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteService(int id) => deleteRequest(id);
}
