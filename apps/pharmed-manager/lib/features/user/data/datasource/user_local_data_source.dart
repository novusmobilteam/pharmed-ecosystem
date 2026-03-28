import '../../../../core/core.dart';

import '../model/user_dto.dart';
import 'user_data_source.dart';

class UserLocalDataSource extends BaseLocalDataSource<UserDTO, int> implements UserDataSource {
  UserLocalDataSource({required String assetPath})
      : super(
          filePath: assetPath,
          fromJson: (m) => UserDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => UserDTO(
            id: id,
            registrationNumber: d.registrationNumber,
            name: d.name,
            surname: d.surname,
            roleId: d.roleId,
            role: d.role,
            isActive: d.isActive,
            type: d.type,
            validUntil: d.validUntil,
            email: d.email,
            isNotOrdered: d.isNotOrdered,
            isWitnessedStationEntry: d.isWitnessedStationEntry,
            kitPurchase: d.kitPurchase,
            userName: d.userName,
            password: d.password,
            stationIds: d.stationIds,
          ),
        );

  @override
  Future<Result<ApiResponse<List<UserDTO>>>> getUsers({
    UserType? type,
    int? skip,
    int? take,
    String? search,
    List<String>? searchFields,
  }) {
    return fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
    );
  }

  @override
  Future<Result<UserDTO?>> createUser(UserDTO dto) => createRequest(dto);

  @override
  Future<Result<UserDTO?>> updateUser(UserDTO dto) => updateRequest(dto);

  @override
  Future<Result<void>> deleteUser(int id) => deleteRequest(id);

  @override
  Future<Result<UserDTO?>> getCurrentUser() async {
    final res = await fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data?.first),
      error: (error) => Result.error(error),
    );
  }

  @override
  Future<Result<void>> bulkUpdateValidDate(DateTime date, List<int> ids) async {
    return Result.ok(null);
  }

  @override
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) async {
    return Result.ok(null);
  }

  @override
  Future<Result<UserDTO?>> witnessUserLogin({
    required String email,
    required String password,
    required String macAddress,
  }) async {
    return Result.ok(null);
  }
}
