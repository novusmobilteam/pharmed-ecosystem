import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/role_datasource.dart';
import '../data/datasource/role_local_datasource.dart';
import '../data/datasource/role_remote_datasource.dart';
import '../data/repository/role_repository.dart';
import '../domain/repository/i_role_repository.dart';
import '../domain/usecase/create_role_usecase.dart';
import '../domain/usecase/delete_role_usecase.dart';
import '../domain/usecase/get_roles_usecase.dart';
import '../domain/usecase/update_role_usecase.dart';

class RoleProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<RoleDataSource>(create: (context) {
        if (isDev) {
          return RoleLocalDataSource(assetPath: 'assets/mocks/role.json');
        } else {
          return RoleRemoteDataSource(apiManager: context.read());
        }
      }),

      // 2. Repository
      Provider<IRoleRepository>(create: (context) => RoleRepository(context.read())),

      // 3. Use Cases
      Provider<CreateRoleUseCase>(create: (context) => CreateRoleUseCase(context.read())),
      Provider<DeleteRoleUseCase>(create: (context) => DeleteRoleUseCase(context.read())),
      Provider<GetRolesUseCase>(create: (context) => GetRolesUseCase(context.read())),
      Provider<UpdateRoleUseCase>(create: (context) => UpdateRoleUseCase(context.read())),
    ];
  }
}
