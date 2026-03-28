import '../../domain/entity/active_ingredient.dart';

class ActiveIngredientDTO {
  final int? id;
  final String? name;
  final bool isActive;

  const ActiveIngredientDTO({
    this.id,
    this.name,
    this.isActive = true,
  });

  factory ActiveIngredientDTO.fromJson(Map<String, dynamic> json) {
    return ActiveIngredientDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }

  ActiveIngredient toEntity() {
    return ActiveIngredient(
      id: id,
      name: name,
      isActive: isActive,
    );
  }

  /// Mock factory for test data generation
  static ActiveIngredientDTO mockFactory(int id) {
    final ingredients = [
      'Parasetamol',
      'Asetilsalisilik Asit',
      'İbuprofen',
      'Naproksen',
      'Diklofenak',
      'Amoksisilin',
      'Klavulanik Asit',
      'Siprofloksasin',
      'Essitalopram',
      'Alprazolam',
      'Tiyokolşikosid',
      'Metamizol',
      'Etodolak',
      'Ketoprofen',
      'Flurbiprofen',
    ];

    return ActiveIngredientDTO(
      id: id,
      name: ingredients[(id - 1) % ingredients.length],
      isActive: true,
    );
  }
}
