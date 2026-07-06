/// EPC'yi 4'erli gruplara böler: "E280...B1" → "E280 6894 ...".
String formatEpc(String epc) {
  final clean = epc.replaceAll(' ', '');
  final chunks = <String>[];
  for (var i = 0; i < clean.length; i += 4) {
    chunks.add(clean.substring(i, (i + 4).clamp(0, clean.length)));
  }
  return chunks.join(' ');
}
