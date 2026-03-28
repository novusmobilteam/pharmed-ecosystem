import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/role_authentication_data_source.dart';
import '../data/datasource/role_authentication_local_data_source.dart';
import '../data/datasource/role_authentication_remote_data_source.dart';
import '../data/datasource/user_authentication_data_source.dart';
import '../data/datasource/user_authentication_local_data_source.dart';
import '../data/datasource/user_authentication_remote_data_source.dart';
import '../data/repository/role_authentication_repository.dart';
import '../data/repository/user_authentication_repository.dart';
import '../domain/repository/i_role_authentication_repository.dart';
import '../domain/repository/i_user_authentication_repository.dart';
import '../domain/usecase/get_role_drug_authentication_usecase.dart';
import '../domain/usecase/get_role_mc_authentication_usecase.dart';
import '../domain/usecase/get_role_menu_authentication_usecase.dart';
import '../domain/usecase/get_user_menu_authentication_usecase.dart';
import '../domain/usecase/save_role_drug_authentication_usecase.dart';
import '../domain/usecase/save_role_mc_authentication_usecase.dart';
import '../domain/usecase/save_role_menu_authentication_usecase.dart';
import '../domain/usecase/save_user_menu_authentication_usecase.dart';

class AuthenticationProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<RoleAuthenticationDataSource>(
        create: (context) {
          if (isDev) {
            final local = RoleAuthenticationLocalDataSource(
              menuPath: '',
              drugPath: '',
              medicalConsumablePath: '',
            );
            return local;
          } else {
            final remote = RoleAuthenticationRemoteDataSource(
              apiManager: context.read(),
            );
            return remote;
          }
        },
      ),

      Provider<UserAuthenticationDataSource>(
        create: (context) {
          if (isDev) {
            final local = UserAuthenticationLocalDataSource(
              filePath: 'assets/mocks/user_authorization.json',
            );
            return local;
          } else {
            final remote = UserAuthenticationRemoteDataSource(
              apiManager: context.read(),
            );
            return remote;
          }
        },
      ),

      // 2. Repository
      Provider<IRoleAuthenticationRepository>(
        create: (context) => RoleAuthenticationRepository(
          context.read<RoleAuthenticationDataSource>(),
        ),
      ),
      Provider<IUserAuthenticationRepository>(
        create: (context) => UserAuthenticationRepository(
          context.read<UserAuthenticationDataSource>(),
        ),
      ),

      // 3. Use Cases
      Provider<GetUserMenuAuthenticationUseCase>(
        create: (context) => GetUserMenuAuthenticationUseCase(
          context.read<IUserAuthenticationRepository>(),
        ),
      ),
      Provider<SaveUserMenuAuthenticationUseCase>(
        create: (context) => SaveUserMenuAuthenticationUseCase(
          context.read<IUserAuthenticationRepository>(),
        ),
      ),

      Provider<GetRoleMenuAuthenticationUseCase>(
        create: (context) => GetRoleMenuAuthenticationUseCase(
          context.read<IRoleAuthenticationRepository>(),
        ),
      ),
      Provider<SaveRoleMenuAuthenticationUseCase>(
        create: (context) => SaveRoleMenuAuthenticationUseCase(
          context.read<IRoleAuthenticationRepository>(),
        ),
      ),

      Provider<GetRoleMcAuthenticationUseCase>(
        create: (context) => GetRoleMcAuthenticationUseCase(
          context.read<IRoleAuthenticationRepository>(),
        ),
      ),
      Provider<SaveRoleMcAuthenticationUseCase>(
        create: (context) => SaveRoleMcAuthenticationUseCase(
          context.read<IRoleAuthenticationRepository>(),
        ),
      ),

      Provider<GetRoleDrugAuthenticationUseCase>(
        create: (context) => GetRoleDrugAuthenticationUseCase(
          authRepository: context.read(),
          medicineRepository: context.read(),
        ),
      ),
      Provider<SaveRoleDrugAuthenticationUseCase>(
        create: (context) => SaveRoleDrugAuthenticationUseCase(
          context.read<IRoleAuthenticationRepository>(),
        ),
      ),
    ];
  }
}
