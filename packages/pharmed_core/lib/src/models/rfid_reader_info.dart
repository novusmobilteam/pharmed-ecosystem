// [SWREQ-RFID-004] [IEC 62304 §5.5]
// RFID okuyucu bilgisi — GetReaderInformation (CMD=0x21) cevabından parse edilir.
// Sınıf: Class A

import 'package:equatable/equatable.dart';

/// RFID okuyucu donanım bilgisi.
///
/// [firmwareVersion] — resp[4].resp[5] → ör. "3.2"
/// [readerType]      — resp[6]
/// [maxPower]        — resp[7] dBm
/// [currentPower]    — resp[8] dBm
class RfidReaderInfo extends Equatable {
  const RfidReaderInfo({
    required this.firmwareVersion,
    required this.readerType,
    required this.maxPower,
    required this.currentPower,
  });

  final String firmwareVersion;
  final int readerType;
  final int maxPower;
  final int currentPower;

  @override
  List<Object?> get props => [firmwareVersion, readerType, maxPower, currentPower];
}
