import '../../../../core/core.dart';
import '../model/drug_class_dto.dart';
import 'drug_class_datasource.dart';

/// İlaç Sınıfı işlemleri için yerel (Mock) veri kaynağı.
class DrugClassLocalDataSource extends BaseLocalDataSource<DrugClassDTO, int> implements DrugClassDataSource {
  DrugClassLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => DrugClassDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => DrugClassDTO(
            id: id,
            name: d.name,
            isActive: d.isActive,
          ),
        );

  @override
  Future<Result<ApiResponse<List<DrugClassDTO>>>> getDrugClasses({
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
  Future<Result<void>> createDrugClass(DrugClassDTO dto) => createRequest(dto);

  @override
  Future<Result<void>> updateDrugClass(DrugClassDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteDrugClassById(int id) => deleteRequest(id);
}
