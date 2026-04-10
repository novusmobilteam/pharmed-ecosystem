import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class HospitalizationProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => HospitalizationRemoteDataSource(apiManager: context.read())),

      Provider<HospitalizationMapper>(create: (_) => const HospitalizationMapper()),

      Provider<IHospitalizationRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => HospitalizationRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev ||
          AppFlavor.prod => HospitalizationRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<CreateHospitalizationUseCase>(create: (context) => CreateHospitalizationUseCase(context.read())),
      Provider<DeleteHospitalizationUseCase>(create: (context) => DeleteHospitalizationUseCase(context.read())),
      Provider<GetFilteredHospitalizationsUseCase>(
        create: (context) => GetFilteredHospitalizationsUseCase(context.read()),
      ),
      Provider<GetHospitalizationsUseCase>(create: (context) => GetHospitalizationsUseCase(context.read())),
      Provider<GetHospitalizationsWithPrescriptionUseCase>(
        create: (context) => GetHospitalizationsWithPrescriptionUseCase(context.read()),
      ),
      Provider<GetPatientsWithActivePrescriptionUseCase>(
        create: (context) => GetPatientsWithActivePrescriptionUseCase(context.read()),
      ),
      Provider<UpdateHospitalizationUseCase>(create: (context) => UpdateHospitalizationUseCase(context.read())),
      Provider<GetHospitalizationsByServiceUseCase>(
        create: (context) => GetHospitalizationsByServiceUseCase(context.read()),
      ),
    ];
  }
}
