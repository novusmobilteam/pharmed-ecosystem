import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:pharmed_manager/features/patient_order_review/domain/usecase/get_patient_prescription_history_usecase.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class PrescriptionProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => PrescriptionRemoteDataSource(apiManager: context.read())),

      Provider<PrescriptionMapper>(create: (_) => const PrescriptionMapper()),
      Provider<PrescriptionItemMapper>(create: (_) => const PrescriptionItemMapper()),

      Provider<IPrescriptionRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => PrescriptionRepositoryImpl(
            dataSource: context.read(),
            prescriptionMapper: context.read(),
            prescriptionItemMapper: context.read(),
          ),
          AppFlavor.dev || AppFlavor.prod => PrescriptionRepositoryImpl(
            dataSource: context.read(),
            prescriptionMapper: context.read(),
            prescriptionItemMapper: context.read(),
          ),
        },
      ),
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
      Provider<DeleteUnscannedBarcodeUseCase>(create: (context) => DeleteUnscannedBarcodeUseCase(context.read())),
      Provider<GetUnscannedBarcodesUseCase>(create: (context) => GetUnscannedBarcodesUseCase(context.read())),
      Provider<ScanBarcodeUseCase>(create: (context) => ScanBarcodeUseCase(context.read())),
      Provider<ToggleBarcodeWarningUseCase>(create: (context) => ToggleBarcodeWarningUseCase(context.read())),
      Provider<GetScannedBarcodesUseCase>(create: (context) => GetScannedBarcodesUseCase(context.read())),
      Provider<GetDeletedBarcodesUseCase>(create: (context) => GetDeletedBarcodesUseCase(context.read())),
      Provider<GetUnappliedPrescriptionsUseCase>(create: (context) => GetUnappliedPrescriptionsUseCase(context.read())),
      Provider<GetUnappliedPrescriptionDetailUseCase>(
        create: (context) => GetUnappliedPrescriptionDetailUseCase(context.read()),
      ),
    ];
  }
}
