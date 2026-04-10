import 'package:equatable/equatable.dart';

/// [SWREQ-RFID-004]
/// GetReaderInformation (CMD=0x21) cevabından parse edilir.
/// Sınıf: Class A
class RfidReaderInfo extends Equatable {
  const RfidReaderInfo({
    required this.firmwareVersion,
    required this.readerType,
    required this.maxPower,
    required this.currentPower,
  });

  final String firmwareVersion; // resp[4].resp[5] → "1.5"
  final int readerType; // resp[6]
  final int maxPower; // resp[7] dBm
  final int currentPower; // resp[8] dBm

  @override
  List<Object?> get props => [firmwareVersion, readerType, maxPower, currentPower];
}
