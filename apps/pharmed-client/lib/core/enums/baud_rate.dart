enum BaudRate {
  baud1200(id: 1, label: "1200"),
  baud2400(id: 2, label: "2400"),
  baud4800(id: 3, label: "4800"),
  baud9600(id: 4, label: "9600"),
  baud19200(id: 5, label: "19200"),
  baud38400(id: 6, label: "38400"),
  baud57600(id: 7, label: "57600"),
  baud115200(id: 8, label: "115200");

  const BaudRate({required this.id, required this.label});

  final int id;
  final String label;

  static BaudRate? fromId(int? id) {
    return BaudRate.values.firstWhere((e) => e.id == id, orElse: () => BaudRate.baud9600);
  }
}
