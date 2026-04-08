import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class BranchProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => BranchRemoteDataSource(apiManager: context.read())),

      Provider<BranchMapper>(create: (_) => const BranchMapper()),

      Provider<IBranchRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => BranchRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev || AppFlavor.prod => BranchRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<GetBranchesUseCase>(create: (context) => GetBranchesUseCase(context.read())),
      Provider<CreateBranchUseCase>(create: (context) => CreateBranchUseCase(context.read())),
      Provider<UpdateBranchUseCase>(create: (context) => UpdateBranchUseCase(context.read())),
      Provider<DeleteBranchUseCase>(create: (context) => DeleteBranchUseCase(context.read())),
    ];
  }
}
