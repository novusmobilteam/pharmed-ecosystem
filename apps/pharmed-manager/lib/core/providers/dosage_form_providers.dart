import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DosageFormProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => DosageFormRemoteDataSource(apiManager: context.read())),

      Provider<DosageFormMapper>(create: (_) => const DosageFormMapper()),

      Provider<IDosageFormRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => DosageFormRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev ||
          AppFlavor.prod => DosageFormRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),
      Provider<GetDosageFormsUseCase>(create: (context) => GetDosageFormsUseCase(context.read())),
      Provider<CreateDosageFormUseCase>(create: (context) => CreateDosageFormUseCase(context.read())),
      Provider<DeleteDosageFormUseCase>(create: (context) => DeleteDosageFormUseCase(context.read())),
      Provider<UpdateDosageFormUseCase>(create: (context) => UpdateDosageFormUseCase(context.read())),
    ];
  }
}
