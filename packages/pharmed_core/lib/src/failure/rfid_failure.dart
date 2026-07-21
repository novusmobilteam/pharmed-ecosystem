// [SWREQ-CLI-RFID-SCAN-001] [IEC 62304 §5.5]
// RFID tarama oturumu hata nedenleri.
// Sınıf: Class B

enum RfidFailure { notConnected, inventoryStartFailed, inventoryStreamError }
