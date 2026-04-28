import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AuthorizationProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => RoleAuthorizationRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => UserAuthorizationRemoteDataSource(apiManager: context.read())),

      Provider<IActiveIngredientRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => ActiveIngredientRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev ||
          AppFlavor.prod => ActiveIngredientRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<RoleMenuAuthorizationMapper>(create: (_) => const RoleMenuAuthorizationMapper()),
      Provider<RoleDrugAuthorizationMapper>(create: (_) => const RoleDrugAuthorizationMapper()),
      Provider<RoleMedicalConsumableAuthorizationMapper>(
        create: (_) => const RoleMedicalConsumableAuthorizationMapper(),
      ),
      Provider<UserMenuAuthorizationMapper>(create: (_) => const UserMenuAuthorizationMapper()),

      Provider<IRoleAuthorizationRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => RoleAuthorizationRepositoryImpl(
            dataSource: context.read(),
            menuMapper: context.read(),
            drugMapper: context.read(),
            consumableMapper: context.read(),
          ),
          AppFlavor.dev || AppFlavor.prod => RoleAuthorizationRepositoryImpl(
            dataSource: context.read(),
            menuMapper: context.read(),
            drugMapper: context.read(),
            consumableMapper: context.read(),
          ),
        },
      ),

      Provider<IUserAuthorizationRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => UserAuthorizationRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev ||
          AppFlavor.prod => UserAuthorizationRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      // 3. Use Cases
      Provider(create: (context) => GetUserMenuAuthorizationUseCase(context.read())),
      Provider(create: (context) => SaveUserMenuAuthorizationUseCase(context.read())),
      Provider(create: (context) => GetRoleMenuAuthorizationUseCase(context.read())),
      Provider(create: (context) => SaveRoleMenuAuthorizationUseCase(context.read())),
      Provider(create: (context) => GetRoleMcAuthorizationUseCase(context.read())),
      Provider(create: (context) => SaveRoleMcAuthorizationUseCase(context.read())),
      Provider(
        create: (context) =>
            GetRoleDrugAuthorizationUseCase(authRepository: context.read(), medicineRepository: context.read()),
      ),
      Provider(create: (context) => SaveRoleDrugAuthorizationUseCase(context.read())),
    ];
  }
}
