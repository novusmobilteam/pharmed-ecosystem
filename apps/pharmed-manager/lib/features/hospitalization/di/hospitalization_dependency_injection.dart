import 'package:pharmed_core/pharmed_core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class HospitalizationProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<HospitalizationDataSource>(
      //   create: (context) {
      //     if (isDev) {
      //       return HospitalizationLocalDataSource(
      //         hospitalizationPath: 'assets/mocks/hospitalization.json',
      //         emergencyPath: 'assets/mocks/emergency_patient.json',
      //       );
      //     } else {
      //       return HospitalizationRemoteDataSource(apiManager: context.read());
      //     }
      //   },
      // ),
      // // 2. Repository
      // Provider<IHospitalizationRepository>(
      //   create: (context) => HospitalizationRepository(context.read<HospitalizationDataSource>()),
      // ),

      // 3. Use Cases
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
