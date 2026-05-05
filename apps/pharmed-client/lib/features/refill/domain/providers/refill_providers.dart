import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/providers/providers.dart';

import '../../refill.dart';

final getPatientPrescriptionHistoryUseCaseProvider = Provider<GetPatientPrescriptionHistoryUseCase>((ref) {
  return GetPatientPrescriptionHistoryUseCase(ref.read(prescriptionRepositoryProvider));
});

final refillMobileCabinUseCaseProvider = Provider<RefillMobileCabinUseCase>((ref) {
  return RefillMobileCabinUseCase(ref.read(cabinStockRepositoryProvider));
});
