import '../../../../core/core.dart';
import '../model/kit_dto.dart';
import 'kit_datasource.dart';

class KitLocalDataSource extends BaseLocalDataSource<KitDTO, int> implements KitDataSource {
  KitLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => KitDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => KitDTO(
            id: id,
            name: d.name,
            normalizedName: d.normalizedName,
            isActive: d.isActive,
          ),
        );

  @override
  Future<Result<List<KitDTO>>> getKits() async {
    final res = await fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createKit(KitDTO dto) => createRequest(dto);

  @override
  Future<Result<void>> updateKit(KitDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteKit(int id) => deleteRequest(id);
}
