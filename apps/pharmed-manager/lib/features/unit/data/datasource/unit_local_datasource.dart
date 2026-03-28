import '../../../../core/core.dart';
import '../model/unit_dto.dart';
import 'unit_datasource.dart';

class UnitLocalDataSource extends BaseLocalDataSource<UnitDTO, int> implements UnitDataSource {
  UnitLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => UnitDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );

  @override
  Future<Result<ApiResponse<List<UnitDTO>>>> getUnits({
    int? skip,
    int? take,
    String? search,
  }) async {
    return fetchRequest(
      skip: skip,
      take: take,
      searchField: 'stationId',
    );
  }

  @override
  Future<Result<UnitDTO?>> createUnit(UnitDTO dto) => createRequest(dto);

  @override
  Future<Result<UnitDTO?>> updateUnit(UnitDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteUnit(int id) => deleteRequest(id);
}
