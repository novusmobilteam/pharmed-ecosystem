import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum Gender {
  female(0),
  male(1),
  unknown(2);

  final int id;

  const Gender(this.id);

  static Gender fromId(int? id) {
    return Gender.values.firstWhere(
      (e) => e.id == id,
      orElse: () => Gender.unknown,
    );
  }

  String get label {
    switch (this) {
      case Gender.female:
        return 'Kadın';
      case Gender.male:
        return 'Erkek';
      case Gender.unknown:
        return 'Bilinmiyor';
    }
  }

  IconData get icon {
    switch (this) {
      case Gender.female:
        return PhosphorIcons.genderFemale();
      case Gender.male:
        return PhosphorIcons.genderMale();
      case Gender.unknown:
        return PhosphorIcons.user();
    }
  }

  Color get color {
    switch (this) {
      case Gender.female:
        return Colors.pink;
      case Gender.male:
        return Colors.blueAccent;
      case Gender.unknown:
        return Colors.grey;
    }
  }
}
