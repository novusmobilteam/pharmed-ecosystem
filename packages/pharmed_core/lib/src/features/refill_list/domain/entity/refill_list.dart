import 'package:pharmed_core/pharmed_core.dart';

class RefillList {
  final int? id;
  final Station? station;
  final User? user;
  final RefillListStatus? status;
  final bool isCancel;
  final bool isFilled;
  final DateTime? date;

  RefillList({this.id, this.station, this.user, this.status, this.isCancel = false, this.isFilled = false, this.date});

  RefillList copyWith({
    int? id,
    Station? station,
    User? user,
    RefillListStatus? status,
    int? statusUserId,
    bool? isCancel,
    bool? isFilled,
    DateTime? date,
  }) {
    return RefillList(
      id: id ?? this.id,
      station: station ?? this.station,
      user: user ?? this.user,
      status: status ?? this.status,
      isCancel: isCancel ?? this.isCancel,
      isFilled: isFilled ?? this.isFilled,
      date: date ?? this.date,
    );
  }

  // Cancel işlemi için özel metod
  RefillList toggleCancelStatus(bool isCancel) {
    return copyWith(isCancel: isCancel);
  }

  RefillList updateStatus() {
    return copyWith(status: status?.nextStatus);
  }
}
