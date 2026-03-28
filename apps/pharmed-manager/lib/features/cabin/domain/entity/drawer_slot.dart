import '../../../../core/core.dart';
import '../../data/model/drawer_slot_dto.dart';
import 'cabin.dart';
import 'drawer_config.dart';

class DrawerSlot extends Selectable {
  final int? drawerConfigId; // DrawerHardwareDTO.id ile eşleşir
  final int? cabinId;
  final int? orderNumber; // Kabin içindeki dikey sıra numarası
  final String? address; // Fiziksel haberleşme adresi
  final int? compartmentNo; // Bölme numarası
  final int? drawrOrderNumber; // Çekmece içi sıralama
  final DrawerConfig? drawerConfig; // İlişkili donanım ayarları (nested)
  final Cabin? cabin; // Bağlı olduğu kabin bilgisi
  final bool? isDeleted;
  final DateTime? createdDate;

  DrawerSlot({
    super.id,
    this.drawerConfigId,
    this.cabinId,
    this.orderNumber,
    this.address,
    this.compartmentNo,
    this.drawrOrderNumber,
    this.drawerConfig,
    this.cabin,
    this.isDeleted,
    this.createdDate,
  }) : super(
          title: cabin?.name ?? 'Serum Kabini',
        );

  DrawerSlot copyWith({
    int? id,
    int? drawerConfigId,
    int? cabinId,
    int? orderNumber,
    String? address,
    int? compartmentNo,
    int? drawrOrderNumber,
    DrawerConfig? drawerConfig,
    Cabin? cabin,
  }) {
    return DrawerSlot(
      id: id ?? this.id,
      drawerConfigId: drawerConfigId ?? this.drawerConfigId,
      cabinId: cabinId ?? this.cabinId,
      orderNumber: orderNumber ?? this.orderNumber,
      address: address ?? this.address,
      compartmentNo: compartmentNo ?? this.compartmentNo,
      drawrOrderNumber: drawrOrderNumber ?? this.drawrOrderNumber,
      drawerConfig: drawerConfig ?? this.drawerConfig,
      cabin: cabin ?? this.cabin,
    );
  }

  DrawerSlotDTO toDTO() {
    return DrawerSlotDTO(
      id: id,
      drawerConfigId: drawerConfigId,
      cabinId: cabinId,
      orderNumber: orderNumber,
      address: address,
      compartmentNo: compartmentNo,
      drawrOrderNumber: drawrOrderNumber,
      drawerConfig: drawerConfig?.toDTO(),
      cabin: cabin?.toDTO(),
    );
  }
}
