import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:pharmed_manager/features/patient_order_review/domain/usecase/get_hospitalized_and_recent_exits_usecase.dart';
import 'package:pharmed_manager/features/urgent_patient/domain/usecase/create_urgent_patient_usecase.dart';
import 'package:pharmed_manager/features/urgent_patient/domain/usecase/get_urgent_patients_usecase.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class PatientProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => PatientRemoteDataSource(apiManager: context.read())),

      Provider<PatientMapper>(create: (_) => const PatientMapper()),
      Provider<MyPatientMapper>(create: (_) => const MyPatientMapper()),
      Provider<UrgentPatientMapper>(create: (_) => const UrgentPatientMapper()),
      Provider<HospitalizationMapper>(create: (_) => const HospitalizationMapper()),

      Provider<IPatientRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => PatientRepository(
            dataSource: context.read(),
            patientMapper: context.read(),
            myPatientMapper: context.read(),
            urgentPatientMapper: context.read(),
            hospitalizationMapper: context.read(),
          ),
          AppFlavor.dev || AppFlavor.prod => PatientRepository(
            dataSource: context.read(),
            patientMapper: context.read(),
            myPatientMapper: context.read(),
            urgentPatientMapper: context.read(),
            hospitalizationMapper: context.read(),
          ),
        },
      ),

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
