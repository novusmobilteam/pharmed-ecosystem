import '../../../../core/core.dart';
import '../model/warning_dto.dart';
import 'warning_datasource.dart';

class WarningLocalDataSource extends BaseLocalDataSource<WarningDTO, int> implements WarningDataSource {
  WarningLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => WarningDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => WarningDTO(
            id: id,
            warningSubjectId: d.warningSubjectId,
            text: d.text,
            isActive: d.isActive,
          ),
        );

  @override
  Future<Result<List<WarningDTO>>> getWarnings() async {
    final res = await fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createWarning(WarningDTO dto) => createRequest(dto);

  @override
  Future<Result<void>> updateWarning(WarningDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteWarning(int id) => deleteRequest(id);
}
