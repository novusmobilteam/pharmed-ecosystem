// [SWREQ-CLI-RFID-SCAN-001]
// RFID tarama oturumunun anlık durumu.
// Sınıf: Class B

class RfidScanSessionState {
  const RfidScanSessionState({required this.isScanning, this.lastError});

  const RfidScanSessionState.initial() : isScanning = false, lastError = null;

  final bool isScanning;
  final String? lastError;

  RfidScanSessionState copyWith({bool? isScanning, String? lastError, bool clearError = false}) {
    return RfidScanSessionState(
      isScanning: isScanning ?? this.isScanning,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}
