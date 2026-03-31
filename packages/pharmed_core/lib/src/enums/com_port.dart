enum ComPort {
  com1(id: 1, label: 'COM1'),
  com2(id: 2, label: 'COM2'),
  com3(id: 3, label: 'COM3'),
  com4(id: 4, label: 'COM4'),
  com5(id: 5, label: 'COM5'),
  com6(id: 6, label: 'COM6'),
  com7(id: 7, label: 'COM7'),
  com8(id: 8, label: 'COM8'),
  com9(id: 9, label: 'COM9'),
  com10(id: 10, label: 'COM10'),
  com11(id: 11, label: 'COM11'),
  com12(id: 12, label: 'COM12'),
  com13(id: 13, label: 'COM13'),
  com14(id: 14, label: 'COM14'),
  com15(id: 15, label: 'COM15'),
  com16(id: 16, label: 'COM16'),
  com17(id: 17, label: 'COM17'),
  com18(id: 18, label: 'COM18'),
  com19(id: 19, label: 'COM19'),
  com20(id: 20, label: 'COM20'),
  com21(id: 21, label: 'COM21'),
  com22(id: 22, label: 'COM22'),
  com23(id: 23, label: 'COM23'),
  com24(id: 24, label: 'COM24');

  const ComPort({required this.id, required this.label});

  final int id;
  final String label;

  static ComPort? fromId(int? id) {
    return ComPort.values.firstWhere((e) => e.id == id, orElse: () => ComPort.com3);
  }
}

extension ComPortX on ComPort {
  static ComPort? fromLabel(String? label) {
    if (label == null) return null;
    return ComPort.values.firstWhere((e) => e.label.toLowerCase() == label.toLowerCase());
  }
}
