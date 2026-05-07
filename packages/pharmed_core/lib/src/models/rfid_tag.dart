// [SWREQ-RFID-001] [IEC 62304 §5.5]
// RFID etiket modeli — okuyucudan parse edilen ham veri.
// Sınıf: Class B

/// UHF RFID etiket verisi.
///
/// [epc]     — 12 byte hex string, evrensel tekil tanımlayıcı (ör. "E280689400005017CFB6")
/// [rssi]    — dBm cinsinden sinyal gücü (signed, tipik: -30 ile -70 arası)
/// [antenna] — etiketi okuyan anten numarası
class RfidTag {
  final String epc;
  final int rssi;
  final int antenna;

  const RfidTag({required this.epc, required this.rssi, required this.antenna});

  @override
  bool operator ==(Object other) => other is RfidTag && other.epc == epc;

  @override
  int get hashCode => epc.hashCode;

  @override
  String toString() => 'RfidTag(epc: $epc, rssi: $rssi dBm, antenna: $antenna)';
}
