/// [ESKİ İSİM: DrawerDTO]
///
/// ÇEKMECE TİPİ / ŞABLONU
/// -----------------------
/// Sistemde sabit tanımlı çekmece tiplerini temsil eder.
/// Her çekmece tipinin temel özelliklerini (adı, göz sayısı, türü vb.) içerir.
///
/// BU MODEL NE İŞE YARAR?
/// 1. Cihaz taraması yapılmadan önce sistemde hangi çekmece tiplerinin
///    tanımlı olduğunu bilmemizi sağlar.
/// 2. Tarama sonucu bulunan çekmece tiplerini buradaki kayıtlarla eşleştiririz.
/// 3. UI'da kullanıcıya "Standart Çekmece", "Kübik Çekmece" gibi seçenekler sunar.
///
/// ÖRNEK DEĞERLER:
/// - id: 1, name: "20 Gözlü Standart Çekmece", compartmentCount: 20, isKubik: false
/// - id: 2, name: "5 Gözlü Serum Kabini", compartmentCount: 5, isKubik: true
/// - id: 3, name: "30 Gözlü Büyük Çekmece", compartmentCount: 30, isKubik: false
///
/// NOT: Cihazdan gelen "v01", "v02" gibi komutlar buradaki kayıtlarla doğrudan
/// eşleşmez. Eşleşme için DrawerConfigDTO (eski DrawerDetailDTO) kullanılır.
class DrawerTypeDTO {
  final int? id;
  final String? name;
  final int? compartmentCount;
  final bool? isMultipleMaterialInput;
  final bool? isKubik;
  final bool? isActive;
  final bool? isDeleted;
  final DateTime? createdDate;

  DrawerTypeDTO({
    this.id,
    this.name,
    this.compartmentCount,
    this.isMultipleMaterialInput,
    this.isKubik,
    this.isActive,
    this.isDeleted,
    this.createdDate,
  });

  factory DrawerTypeDTO.fromJson(Map<String, dynamic> json) {
    return DrawerTypeDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      compartmentCount: json['compartmentCount'] as int?,
      isMultipleMaterialInput: json['isMultipleMaterialInput'] as bool?,
      isKubik: json['isKubik'] as bool?,
      isActive: json['isActive'] as bool?,
      isDeleted: json['isDeleted'] as bool?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'compartmentCount': compartmentCount,
      'isMultipleMaterialInput': isMultipleMaterialInput,
      'isKubik': isKubik,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdDate': createdDate,
    };
  }

  DrawerTypeDTO copyWith({
    int? id,
    String? name,
    int? compartmentCount,
    bool? isMultipleMaterialInput,
    bool? isKubik,
    bool? isActive,
  }) {
    return DrawerTypeDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      compartmentCount: compartmentCount ?? this.compartmentCount,
      isMultipleMaterialInput: isMultipleMaterialInput ?? this.isMultipleMaterialInput,
      isKubik: isKubik ?? this.isKubik,
      isActive: isActive ?? this.isActive,
    );
  }
}
