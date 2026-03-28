import '../../../../core/core.dart';
import '../model/firm_dto.dart';
import 'firm_data_source.dart';

class FirmLocalDataSource extends BaseLocalDataSource<FirmDTO, int> implements FirmDataSource {
  FirmLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => FirmDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => FirmDTO(
            id: id,
            name: d.name,
            taxOffice: d.taxOffice,
            taxNo: d.taxNo,
            firmTypeId: d.firmTypeId,
          ),
        );

  @override
  Future<Result<ApiResponse<List<FirmDTO>>>> getFirms({int? skip, int? take, String? search}) => fetchRequest();

  @override
  Future<Result<FirmDTO?>> createFirm(FirmDTO dto) => createRequest(dto);

  @override
  Future<Result<FirmDTO?>> updateFirm(FirmDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteFirm(int id) => deleteRequest(id);
}
