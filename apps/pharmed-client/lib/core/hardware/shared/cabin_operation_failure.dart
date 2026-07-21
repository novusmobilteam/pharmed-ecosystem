// Kabin operasyonu sırasında oluşabilecek hata tipleri.
// FatalError state'leri bu sealed class üzerinden taşır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import 'cabin_validation_reason_extension.dart';

sealed class CabinOperationFailure {
  const CabinOperationFailure();
}

final class CabinDrawerFailure extends CabinOperationFailure {
  const CabinDrawerFailure({required this.failure, this.detail});

  final MobileDrawerFailure failure;
  final String? detail;
}

final class CabinMasterDrawerFailure extends CabinOperationFailure {
  const CabinMasterDrawerFailure({required this.failure, this.detail});

  final MasterDrawerFailure failure;
  final String? detail;
}

final class CabinRfidFailure extends CabinOperationFailure {
  const CabinRfidFailure({required this.failure, this.detail});

  final RfidFailure failure;
  final String? detail;
}

// cabin_operation_failure.dart'a eklenir
final class CabinApiFailure extends CabinOperationFailure {
  const CabinApiFailure({required this.message});

  final String message;
}

final class CabinValidationFailure extends CabinOperationFailure {
  const CabinValidationFailure({required this.reason});

  final CabinValidationReason reason;
}
