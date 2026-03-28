import '../../../../core/core.dart';
import '../model/drug_type_dto.dart';
import 'drug_type_datasource.dart';

/// İlaç Türü işlemleri için yerel (Mock) veri kaynağı.
class DrugTypeLocalDataSource extends BaseLocalDataSource<DrugTypeDTO, int> implements DrugTypeDataSource {
  DrugTypeLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => DrugTypeDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => DrugTypeDTO(
            id: id,
            name: d.name,
            isActive: d.isActive,
          ),
        );

  @override
  Future<Result<ApiResponse<List<DrugTypeDTO>>>> getDrugTypes({
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
  Future<Result<void>> createDrugType(DrugTypeDTO dto) => createRequest(dto);

  @override
  Future<Result<void>> updateDrugType(DrugTypeDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteDrugType(int id) => deleteRequest(id);
}
