// [SWREQ-CLI-CABIN-OP-011] [IEC 62304 §5.5]
// Master kabin çekmece oturumu hata nedenleri.
// Sınıf: Class B

enum MasterDrawerFailure {
  managerNotFound,
  managerConnectFailed,
  lockOpenFailed,
  lidOpenFailed,
  lockOpenTimeout,
  sensorCommunicationLost,
  unexpectedlyClosed,
}
