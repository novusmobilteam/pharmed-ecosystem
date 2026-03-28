import '../../../../core/core.dart';
import '../../domain/entity/firm.dart';

class FirmDTO {
  final int? id;
  final String? name;
  final String? taxOffice;
  final int? taxNo;
  final int? firmTypeId;

  const FirmDTO({this.id, this.name, this.taxOffice, this.taxNo, this.firmTypeId});

  factory FirmDTO.fromJson(Map<String, dynamic> json) {
    return FirmDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      taxOffice: json['taxOffice'] as String?,
      taxNo: json['taxNo'] as int?,
      firmTypeId: json['firmTypeId'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'taxOffice': taxOffice,
    'taxNo': taxNo,
    'firmTypeId': firmTypeId,
  };

  Firm toEntity() => Firm(id: id, name: name, taxOffice: taxOffice, taxNo: taxNo, type: firmTypeFromId(firmTypeId));

  FirmDTO copyWith({int? id, String? name, String? taxOffice, int? taxNo, int? firmTypeId}) {
    return FirmDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      taxOffice: taxOffice ?? this.taxOffice,
      taxNo: taxNo ?? this.taxNo,
      firmTypeId: firmTypeId ?? this.firmTypeId,
    );
  }

  /// Mock factory for test data generation
  static FirmDTO mockFactory(int id) {
    final firmNames = [
      'Abdi İbrahim',
      'Eczacıbaşı',
      'Sanofi',
      'Bayer',
      'Pfizer',
      'Novartis',
      'Roche',
      'GSK',
      'AstraZeneca',
      'Johnson & Johnson',
      'Bilim İlaç',
      'Deva Holding',
      'Nobel İlaç',
      'Koçak Farma',
      'Santa Farma',
      'Mustafa Nevzat',
      'İE Ulagay',
    ];

    final taxOffices = ['Beşiktaş', 'Kadıköy', 'Şişli', 'Üsküdar', 'Beyoğlu'];

    return FirmDTO(
      id: id,
      name: firmNames[(id - 1) % firmNames.length],
      taxOffice: '${taxOffices[(id - 1) % taxOffices.length]} Vergi Dairesi',
      taxNo: 1000000000 + (id * 123456789 % 900000000),
      firmTypeId: ((id - 1) % 3) + 1,
    );
  }
}
