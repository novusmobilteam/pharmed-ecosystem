import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RoleProviders {
  static List<SingleChildWidget> providers() {
    return [
      Provider<RoleRemoteDataSource>(create: (context) => RoleRemoteDataSource(apiManager: context.read<APIManager>())),

      Provider<RoleMapper>(create: (_) => const RoleMapper()),

      Provider<IRoleRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => RoleRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev || AppFlavor.prod => RoleRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<GetRolesUseCase>(create: (context) => GetRolesUseCase(context.read<IRoleRepository>())),
      Provider<CreateRoleUseCase>(create: (context) => CreateRoleUseCase(context.read<IRoleRepository>())),
      Provider<UpdateRoleUseCase>(create: (context) => UpdateRoleUseCase(context.read<IRoleRepository>())),
      Provider<DeleteRoleUseCase>(create: (context) => DeleteRoleUseCase(context.read<IRoleRepository>())),
    ];
  }
}
