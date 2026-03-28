import '../../domain/entity/system_parameter.dart';

class SystemParameterDTO {
  final int? id;
  final String? type;
  final String? category;
  final String? key;
  final String? value;
  final String? description;
  final bool? isDeleted;

  SystemParameterDTO({
    this.id,
    this.type,
    this.category,
    this.key,
    this.value,
    this.description,
    this.isDeleted,
  });

  factory SystemParameterDTO.fromJson(Map<String, dynamic> json) {
    return SystemParameterDTO(
      id: json['id'],
      type: json['type'],
      category: json['category'],
      key: json['key'],
      value: json['value'],
      description: json['description'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'key': key,
      'value': value,
      'description': description,
      'isDeleted': isDeleted,
    };
  }

  SystemParameter toEntity() {
    return SystemParameter(
      id: id,
      type: type,
      category: category,
      key: key,
      value: value,
      description: description,
      isDeleted: isDeleted,
    );
  }
}
