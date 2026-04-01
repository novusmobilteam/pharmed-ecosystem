import 'package:pharmed_core/pharmed_core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../patient_order_review/domain/usecase/get_patient_prescription_history_usecase.dart';

class PrescriptionProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<PrescriptionDataSource>(
      //   create: (context) {
      //     if (isDev) {
      //       return PrescriptionLocalDataSource(
      //         prescriptionsPath: 'assets/mocks/prescription.json',
      //         itemsPath: 'assets/mocks/prescription_detail.json',
      //         otherRequestsPath: 'assets/mocks/prescription_other_request.json',
      //       );
      //     } else {
      //       return PrescriptionRemoteDataSource(apiManager: context.read());
      //     }
      //   },
      // ),

      // // 2. Repository
      // Provider<IPrescriptionRepository>(create: (context) => PrescriptionRepository(context.read())),

      // 3. Use Case
      Provider<CreatePrescriptionWithProductsUseCase>(
        create: (context) => CreatePrescriptionWithProductsUseCase(prescriptionRepository: context.read()),
      ),

      Provider<GetPatientPrescriptionsUseCase>(create: (context) => GetPatientPrescriptionsUseCase(context.read())),
      Provider<GetPrescriptionDetailUseCase>(create: (context) => GetPrescriptionDetailUseCase(context.read())),
      Provider<SubmitPrescriptionActionUseCase>(create: (context) => SubmitPrescriptionActionUseCase(context.read())),
      Provider<UpdatePrescriptionItemUseCase>(create: (context) => UpdatePrescriptionItemUseCase(context.read())),
      Provider<GetPatientPrescriptionHistoryUseCase>(
        create: (context) => GetPatientPrescriptionHistoryUseCase(context.read()),
      ),
    ];
  }
}
