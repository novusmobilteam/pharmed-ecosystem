class RfidTag {
  final String epc; // 12 byte hex string, unique identifier
  final int rssi; // dBm cinsinden sinyal gücü
  final int antenna; // anten numarası

  const RfidTag({required this.epc, required this.rssi, required this.antenna});

  @override
  bool operator ==(Object other) => other is RfidTag && other.epc == epc;

  @override
  int get hashCode => epc.hashCode;

  @override
  String toString() => 'RfidTag(epc: $epc, rssi: $rssi dBm)';
}
