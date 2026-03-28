import '../../data/model/drawer_type_dto.dart';

/// [ESKİ İSİM: Drawer]
///
/// ÇEKMECE TİPİ ENTITY'Sİ
/// -----------------------
/// Domain katmanında çekmece tipini temsil eden entity.
/// Bu entity, business logic işlemlerinde kullanılır ve
/// data katmanındaki DrawerTypeDTO'dan bağımsızdır.
///
/// KULLANIM YERLERİ:
/// 1. Use case'lerde business logic
/// 2. ViewModel'lerde state yönetimi
/// 3. UI'da çekmece tipi bilgilerini göstermek
///
/// ÖZELLİKLER:
/// - Value object olarak tasarlanmıştır (immutable)
/// - Business validation kurallarını içerir
/// - DTO'dan bağımsız domain mantığı barındırır
class DrawerType {
  final int? id;
  final String? name;
  final int? compartmentCount;
  final bool? isMultipleMaterialInput;
  final bool? isKubik;
  final bool? isActive;
  final bool? isDeleted;
  final DateTime? createdDate;

  DrawerType({
    this.id,
    this.name,
    this.compartmentCount,
    this.isMultipleMaterialInput = false,
    this.isKubik = false,
    this.isActive = false,
    this.isDeleted = false,
    this.createdDate,
  });

  DrawerType copyWith({
    int? id,
    String? name,
    int? compartmentCount,
    bool? isMultipleMaterialInput,
    bool? isKubik,
    bool? isActive,
  }) {
    return DrawerType(
      id: id ?? this.id,
      name: name ?? this.name,
      compartmentCount: compartmentCount ?? this.compartmentCount,
      isMultipleMaterialInput: isMultipleMaterialInput ?? this.isMultipleMaterialInput,
      isKubik: isKubik ?? this.isKubik,
      isActive: isActive ?? this.isActive,
    );
  }

  DrawerTypeDTO toDTO() {
    return DrawerTypeDTO(
      id: id,
      name: name,
      compartmentCount: compartmentCount,
      isMultipleMaterialInput: isMultipleMaterialInput,
      isKubik: isKubik,
      isActive: isActive,
    );
  }
}
