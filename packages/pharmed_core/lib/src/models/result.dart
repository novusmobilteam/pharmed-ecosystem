// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pharmed_core/src/failure/app_exceptions.dart';

/// Utility class to wrap result data
///
/// Evaluate the result using a `when` method:
/// ```dart
/// final result = fetchSomeData();
/// result.when(
///   ok: (value) {
///     print(value);
///   },
///   error: (error) {
///     print(error);
///   },
/// );
/// ```

sealed class Result<T> {
  const Result();

  /// Creates a successful [Result], completed with the specified [value].
  const factory Result.ok(T value) = Ok._;

  /// Creates an error [Result], completed with the specified [error].
  const factory Result.error(AppException error) = Error._;

  /// Evaluate the result based on its type.
  R when<R>({required R Function(T value) ok, required R Function(AppException error) error});

  T? get data => this is Ok<T> ? (this as Ok<T>).value : null;

  bool get isSuccess => this is Ok<T>;
  bool get isError => this is Error<T>;
}

/// Subclass of Result for values
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// Returned value in result
  final T value;

  @override
  R when<R>({required R Function(T value) ok, required R Function(AppException error) error}) {
    return ok(value);
  }

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Subclass of Result for errors
final class Error<T> extends Result<T> {
  const Error._(this.error);

  /// Returned error in result
  final AppException error;

  @override
  R when<R>({required R Function(T value) ok, required R Function(AppException error) error}) {
    return error(this.error);
  }

  @override
  String toString() => 'Result<$T>.error($error)';
}
