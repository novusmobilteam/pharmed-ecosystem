import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../patient_order_review/domain/usecase/get_hospitalized_and_recent_exits_usecase.dart';
import '../../urgent_patient/domain/usecase/create_urgent_patient_usecase.dart';
import '../../urgent_patient/domain/usecase/get_urgent_patients_usecase.dart';

class PatientProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<PatientDataSource>(
      //   create: (context) {
      //     if (isDev) {
      //       return PatientLocalDataSource(assetPath: 'assets/mocks/patient.json');
      //     } else {
      //       return PatientRemoteDataSource(apiManager: context.read());
      //     }
      //   },
      // ),

      // // 2. Repository
      // Provider<IPatientRepository>(
      //   create: (context) => PatientRepository(context.read()),
      // ),

      // 3. Use Cases
      Provider<AddPatientUseCase>(create: (context) => AddPatientUseCase(context.read())),
      Provider<CreatePatientUseCase>(create: (context) => CreatePatientUseCase(context.read())),
      Provider<DeletePatientUseCase>(create: (context) => DeletePatientUseCase(context.read())),
      Provider<GetMyPatientsUseCase>(create: (context) => GetMyPatientsUseCase(context.read())),
      Provider<GetPatientsUseCase>(create: (context) => GetPatientsUseCase(context.read())),
      Provider<RemovePatientsUseCase>(create: (context) => RemovePatientsUseCase(context.read())),
      Provider<UpdatePatientUseCase>(create: (context) => UpdatePatientUseCase(context.read())),
      Provider<EndEmergencyPatientUseCase>(create: (context) => EndEmergencyPatientUseCase(context.read())),
      Provider<GetHospitalizedAndRecentExitsUseCase>(
        create: (context) => GetHospitalizedAndRecentExitsUseCase(context.read()),
      ),
      Provider<GetUrgentPatientsUseCase>(create: (context) => GetUrgentPatientsUseCase(context.read())),
      Provider<CreateUrgentPatientUseCase>(create: (context) => CreateUrgentPatientUseCase(context.read())),
    ];
  }
}
