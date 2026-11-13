/// Kabin donanımı servisleri (RS485 seri port, yönetim/çekmece/kübik kartları,
/// UHFEx10 RFID okuyucu) ve çevre birimi sürücüleri (SecuGen / Suprema BioMini
/// parmak izi okuyucu, ESC/POS fiş yazıcı). SDK DLL'leri: `third_party/`.
///
/// Arayüzler ([ISerialCommunicationService], [ICabinOperationService]) `pharmed_core`'dadır;
/// bu paket gerçek ve sahte (mock) uygulamalarını içerir. Protokol:
/// `docs/hardware/rs485-protokol.md`.
library pharmed_hardware;

export 'src/cabin_operation/cabin_operation_service.dart';
export 'src/cabin_operation/mock_cabin_operation_service.dart';
export 'src/fingerprint/fingerprint.dart';
export 'src/printer/printer.dart';
export 'src/rfid/mock_rfid_service.dart';
export 'src/rfid/rfid_service.dart';
export 'src/serial_communication/mock_serial_communication_service.dart';
export 'src/serial_communication/serial_communication_service.dart';
export 'src/serial_communication/serial_port_lifecycle_observer.dart';
