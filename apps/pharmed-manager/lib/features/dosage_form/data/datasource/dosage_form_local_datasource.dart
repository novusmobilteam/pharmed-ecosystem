import '../../../../core/core.dart';
import '../model/dosage_form_dto.dart';
import 'dosage_form_datasource.dart';

class DosageFormLocalDataSource extends BaseLocalDataSource<DosageFormDTO, int> implements DosageFormDataSource {
  DosageFormLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => DosageFormDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => DosageFormDTO(
            id: id,
            name: d.name,
            isActive: d.isActive,
          ),
        );

  @override
  Future<Result<ApiResponse<List<DosageFormDTO>>>> getDosageForms({
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
  Future<Result<DosageFormDTO?>> createDosageForm(DosageFormDTO dto) => createRequest(dto);

  @override
  Future<Result<DosageFormDTO?>> updateDosageForm(DosageFormDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteDosageForm(int id) => deleteRequest(id);
}
