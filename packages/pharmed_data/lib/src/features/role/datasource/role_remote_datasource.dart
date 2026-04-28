// packages/pharmed_data/lib/src/role/datasource/role_remote_datasource.dart
//
// [SWREQ-DATA-ROLE-001]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RoleRemoteDataSource extends BaseRemoteDataSource {
  RoleRemoteDataSource({required super.apiManager});

  static const _base = '/Role';

  @override
  String get logUnit => 'SW-UNIT-ROLE';

  @override
  String get logSwreq => 'SWREQ-DATA-ROLE-001';

  Future<Result<ApiResponse<List<RoleDTO>>?>> getRoles({int? skip, int? take, String? search}) {
    return fetchRequest(
      path: _base,
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      parser: BaseRemoteDataSource.apiResponseListParser(RoleDTO.fromJson),
      successLog: 'Roller getirildi',
      emptyLog: 'Rol bulunamadı',
    );
  }

  Future<Result<void>> createRole(RoleDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Rol oluşturuldu',
    );
  }

  Future<Result<void>> updateRole(RoleDTO dto) {
    return updateRequest(
      path: '$_base/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Rol güncellendi',
    );
  }

  Future<Result<void>> deleteRole(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'Rol silindi');
  }
}
