import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/model/system_parameter_dto.dart';

enum ParameterValueType {
  @JsonValue('Int32')
  int32,
  @JsonValue('String')
  string,
  @JsonValue('Boolean')
  boolean,
}

class SystemParameter {
  final int? id;
  final String? type;
  final String? category;
  final String? key;
  final String? value;
  final String? description;
  final bool? isDeleted;

  SystemParameter({
    this.id,
    this.type,
    this.category,
    this.key,
    this.value,
    this.description,
    this.isDeleted,
  });

  SystemParameterDTO toDTO() {
    return SystemParameterDTO(
      id: id,
      type: type,
      category: category,
      key: key,
      value: value,
      description: description,
      isDeleted: isDeleted,
    );
  }

  SystemParameter copyWith({String? value}) {
    return SystemParameter(
      id: id,
      type: type,
      category: category,
      key: key,
      value: value ?? this.value,
      description: description,
      isDeleted: isDeleted,
    );
  }
}
