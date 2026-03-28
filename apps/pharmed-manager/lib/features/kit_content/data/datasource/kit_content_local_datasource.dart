import '../../../../core/core.dart';
import '../model/kit_content_dto.dart';
import 'kit_content_datasource.dart';

class KitContentLocalDataSource extends BaseLocalDataSource<KitContentDTO, int> implements KitContentDataSource {
  KitContentLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => KitContentDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => KitContentDTO.fromJson(
            {...d.toJson(), 'id': id},
          ),
        );

  @override
  Future<Result<KitContentDTO?>> createKitContent(KitContentDTO dto) => createRequest(dto);

  @override
  Future<Result<void>> deleteKitContent(int kitId) => deleteRequest(kitId);

  @override
  Future<Result<List<KitContentDTO>>> getKitContent(int kitId) async {
    final res = await fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<KitContentDTO?>> updateKitContent(KitContentDTO dto) => updateRequest(dto);
}
