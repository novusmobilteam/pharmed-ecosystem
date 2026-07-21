import 'package:pharmed_core/pharmed_core.dart';

class Kit {
  final int? id;
  final String? name;
  final String? normalizedName;
  final bool? isActive;

  Kit({this.id, this.name, this.normalizedName, this.isActive});

  Status get status => (isActive ?? false) ? Status.active : Status.passive;

  Kit copyWith({int? id, String? name, String? normalizedName, bool? isActive}) {
    return Kit(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      isActive: isActive ?? this.isActive,
    );
  }
}
