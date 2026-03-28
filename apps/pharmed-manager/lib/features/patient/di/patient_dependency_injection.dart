import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../patient_order_review/domain/usecase/get_hospitalized_and_recent_exits_usecase.dart';
import '../../urgent_patient/domain/usecase/create_urgent_patient_usecase.dart';
import '../../urgent_patient/domain/usecase/get_urgent_patients_usecase.dart';
import '../data/datasource/patient_datasource.dart';
import '../data/datasource/patient_local_datasource.dart';
import '../data/datasource/patient_remote_datasource.dart';
import '../data/repository/patient_repository.dart';
import '../domain/repository/i_patient_repository.dart';
import '../domain/usecase/add_patient_usecase.dart';
import '../domain/usecase/create_patient_usecase.dart';
import '../domain/usecase/delete_patient_usecase.dart';
import '../domain/usecase/end_emergency_patient_usecase.dart';
import '../domain/usecase/get_my_patients_usecase.dart';
import '../domain/usecase/get_patients_usecase.dart';
import '../domain/usecase/remove_patient_usecase.dart';
import '../domain/usecase/update_patient_usecase.dart';

class PatientProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<PatientDataSource>(
        create: (context) {
          if (isDev) {
            return PatientLocalDataSource(assetPath: 'assets/mocks/patient.json');
          } else {
            return PatientRemoteDataSource(apiManager: context.read());
          }
        },
      ),

      // 2. Repository
      Provider<IPatientRepository>(
        create: (context) => PatientRepository(context.read()),
      ),

      // 3. Use Cases
      Provider<AddPatientUseCase>(
        create: (context) => AddPatientUseCase(context.read()),
      ),
      Provider<CreatePatientUseCase>(
        create: (context) => CreatePatientUseCase(context.read()),
      ),
      Provider<DeletePatientUseCase>(
        create: (context) => DeletePatientUseCase(context.read()),
      ),
      Provider<GetMyPatientsUseCase>(
        create: (context) => GetMyPatientsUseCase(context.read()),
      ),
      Provider<GetPatientsUseCase>(
        create: (context) => GetPatientsUseCase(context.read()),
      ),
      Provider<RemovePatientsUseCase>(
        create: (context) => RemovePatientsUseCase(context.read()),
      ),
      Provider<UpdatePatientUseCase>(
        create: (context) => UpdatePatientUseCase(context.read()),
      ),
      Provider<EndEmergencyPatientUseCase>(
        create: (context) => EndEmergencyPatientUseCase(context.read()),
      ),
      Provider<GetHospitalizedAndRecentExitsUseCase>(
        create: (context) => GetHospitalizedAndRecentExitsUseCase(context.read()),
      ),
      Provider<GetUrgentPatientsUseCase>(
        create: (context) => GetUrgentPatientsUseCase(context.read()),
      ),
      Provider<CreateUrgentPatientUseCase>(
        create: (context) => CreateUrgentPatientUseCase(context.read()),
      ),
    ];
  }
}
