import '../../../../core/core.dart';
import '../../data/model/filling_list_dto.dart';
import '../../../station/domain/entity/station.dart';

class FillingList implements TableData {
  final int? id;
  final Station? station;
  final User? user;
  final FillingRecordStatus? status;
  final bool isCancel;
  final bool isFilled;
  final DateTime? date;

  @override
  List<dynamic> get content => [
    //station?.name,
    user?.fullName,
    date?.formattedDate,
    status?.label,
    isCancel,
  ];

  @override
  List get rawContent => [
    //station?.name,
    user?.fullName,
    date,
    status?.label,
    isCancel,
  ];

  @override
  List<String?> get titles => [
    //'İstasyon',
    'Kullanıcı',
    'Tarih',
    'Durum',
    'İptal',
  ];

  FillingList({this.id, this.station, this.user, this.status, this.isCancel = false, this.isFilled = false, this.date});

  FillingList copyWith({
    int? id,
    Station? station,
    User? user,
    FillingRecordStatus? status,
    int? statusUserId,
    bool? isCancel,
    bool? isFilled,
    DateTime? date,
  }) {
    return FillingList(
      id: id ?? this.id,
      station: station ?? this.station,
      user: user ?? this.user,
      status: status ?? this.status,
      isCancel: isCancel ?? this.isCancel,
      isFilled: isFilled ?? this.isFilled,
      date: date ?? this.date,
    );
  }

  FillingListDTO toDTO() {
    return FillingListDTO(
      id: id,
      stationId: station?.id,
      station: station?.toDTO(),
      user: const UserMapper().toDtoOrNull(user),
      statusId: status?.id,
      isCancel: isCancel,
      isFilled: isFilled,
      date: date,
    );
  }

  // Cancel işlemi için özel metod
  FillingList toggleCancelStatus(bool isCancel) {
    return copyWith(isCancel: isCancel);
  }

  FillingList updateStatus() {
    return copyWith(status: status?.nextStatus);
  }
}
