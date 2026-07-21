// [SWREQ-CLI-RFID-SCAN-001] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class RfidScanSessionState {
  const RfidScanSessionState({required this.isScanning, this.failure, this.errorDetail});

  const RfidScanSessionState.initial() : isScanning = false, failure = null, errorDetail = null;

  final bool isScanning;
  final RfidFailure? failure;
  final String? errorDetail;

  bool get hasError => failure != null;

  RfidScanSessionState copyWith({
    bool? isScanning,
    RfidFailure? failure,
    String? errorDetail,
    bool clearError = false,
  }) {
    return RfidScanSessionState(
      isScanning: isScanning ?? this.isScanning,
      failure: clearError ? null : (failure ?? this.failure),
      errorDetail: clearError ? null : (errorDetail ?? this.errorDetail),
    );
  }
}
