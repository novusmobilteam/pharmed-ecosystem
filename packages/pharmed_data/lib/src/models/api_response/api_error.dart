import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';
part 'api_error.g.dart';

@freezed
abstract class ApiError with _$ApiError {
  const factory ApiError({
    @JsonKey(name: 'error') String? error,
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'isSuccess') bool? isSuccess,
    @JsonKey(name: 'statusCode') int? statusCode,
  }) = _ApiError;

  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);
}
