// apps/pharmed_manager/lib/features/role/di/role_providers.dart

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class RoleProviders {
  static List<SingleChildWidget> get providers => [
    // 1. Mapper
    Provider<RoleMapper>(create: (_) => const RoleMapper()),

    // 2. DataSource
    Provider<RoleRemoteDataSource>(create: (context) => RoleRemoteDataSource(apiManager: context.read<APIManager>())),

    // 3. Repository
    Provider<IRoleRepository>(
      create: (context) =>
          RoleRepositoryImpl(dataSource: context.read<RoleRemoteDataSource>(), mapper: context.read<RoleMapper>()),
    ),

    // 4. Use Cases
    Provider<GetRolesUseCase>(create: (context) => GetRolesUseCase(context.read<IRoleRepository>())),
    Provider<CreateRoleUseCase>(create: (context) => CreateRoleUseCase(context.read<IRoleRepository>())),
    Provider<UpdateRoleUseCase>(create: (context) => UpdateRoleUseCase(context.read<IRoleRepository>())),
    Provider<DeleteRoleUseCase>(create: (context) => DeleteRoleUseCase(context.read<IRoleRepository>())),
  ];
}
