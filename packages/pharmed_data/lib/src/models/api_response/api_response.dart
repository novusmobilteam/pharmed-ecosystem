import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    @JsonKey(name: 'data') T? data,
    @JsonKey(name: 'statusCode') int? statusCode,
    @JsonKey(name: 'isSuccess') bool? isSuccess,
    @JsonKey(name: 'totalCount') int? totalCount,
    @JsonKey(name: 'groupCount') int? groupCount,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$ApiResponseFromJson(json, fromJsonT);
}
