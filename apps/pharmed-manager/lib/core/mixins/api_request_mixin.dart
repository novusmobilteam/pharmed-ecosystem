// [SWREQ-UI-MIXIN-001]
// [IEC 62304 Class B]
// Her Notifier'da kullanılan operation yönetim mixin'i.
// Result<T> → UiState dönüşümünü merkezi olarak yönetir.
// Her operation MedLogger ile izlenir.

import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';

enum OperationType { fetch, create, update, delete, submit, custom }

class OperationKey {
  final OperationType type;
  final String? customKey;

  const OperationKey(this.type, {this.customKey});
  const OperationKey.fetch() : this(OperationType.fetch);
  const OperationKey.create() : this(OperationType.create);
  const OperationKey.update() : this(OperationType.update);
  const OperationKey.delete() : this(OperationType.delete);
  const OperationKey.submit() : this(OperationType.submit);
  const OperationKey.custom(String k) : this(OperationType.custom, customKey: k);

  @override
  bool operator ==(Object other) => other is OperationKey && type == other.type && customKey == other.customKey;

  @override
  int get hashCode => type.hashCode ^ customKey.hashCode;

  @override
  String toString() => customKey ?? type.name;
}

class OperationStatus {
  final OperationKey key;
  final APIRequestStatus status;
  final String? message;
  final dynamic data;

  const OperationStatus({required this.key, required this.status, this.message, this.data});

  bool get isLoading => status == APIRequestStatus.loading;
  bool get isSuccess => status == APIRequestStatus.success;
  bool get isFailed => status == APIRequestStatus.failed;
  bool get isInitial => status == APIRequestStatus.initial;
}

// ─────────────────────────────────────────────────────────────────
// ApiRequestMixin
// [SWREQ-UI-MIXIN-001] [IEC 62304 Class B]
// ─────────────────────────────────────────────────────────────────

mixin ApiRequestMixin on ChangeNotifier {
  /// Log context için override edilebilir
  String get notifierName => runtimeType.toString();

  final Map<OperationKey, OperationStatus> _operations = {};
  final Map<OperationKey, VoidCallback> _onLoadingCallbacks = {};
  final Map<OperationKey, void Function(String?)> _onErrorCallbacks = {};
  final Map<OperationKey, void Function(String)> _onSuccessCallbacks = {};

  // ── Getters ───────────────────────────────────────────────────

  OperationStatus? operationStatus(OperationKey key) => _operations[key];
  bool isLoading(OperationKey key) => _operations[key]?.isLoading ?? false;
  bool isSuccess(OperationKey key) => _operations[key]?.isSuccess ?? false;
  bool isFailed(OperationKey key) => _operations[key]?.isFailed ?? false;
  String? message(OperationKey key) => _operations[key]?.message;
  bool get anyLoading => _operations.values.any((s) => s.isLoading);
  bool areLoading(List<OperationKey> keys) => keys.any(isLoading);
  bool hasError(OperationKey key) => isFailed(key);

  // ── Callback registration ─────────────────────────────────────

  void setCallbacks({
    required OperationKey key,
    VoidCallback? onLoading,
    void Function(String?)? onError,
    void Function(String)? onSuccess,
  }) {
    if (onLoading != null) _onLoadingCallbacks[key] = onLoading;
    if (onError != null) _onErrorCallbacks[key] = onError;
    if (onSuccess != null) _onSuccessCallbacks[key] = onSuccess;
  }

  // ── State setters ─────────────────────────────────────────────

  void setLoading(OperationKey key, {String? message}) =>
      _setOperation(key, APIRequestStatus.loading, message: message);

  void setSuccess(OperationKey key, {String? message, dynamic data}) =>
      _setOperation(key, APIRequestStatus.success, message: message, data: data);

  void setFailed(OperationKey key, {required String message, dynamic data}) =>
      _setOperation(key, APIRequestStatus.failed, message: message, data: data);

  void clearOperation(OperationKey key) {
    _operations.remove(key);
    notifyListeners();
  }

  void clearAllOperations() {
    _operations.clear();
    notifyListeners();
  }

  void _setOperation(OperationKey key, APIRequestStatus status, {String? message, dynamic data}) {
    _operations[key] = OperationStatus(key: key, status: status, message: message, data: data);
    notifyListeners();

    switch (status) {
      case APIRequestStatus.loading:
        _onLoadingCallbacks[key]?.call();

      case APIRequestStatus.success:
        final msg = message ?? 'İşlem başarılı';
        _onSuccessCallbacks[key]?.call(msg);
        MedLogger.info(
          unit: 'SW-UNIT-UI',
          swreq: 'SWREQ-UI-MIXIN-001',
          message: '$notifierName.$key → success',
          context: message != null ? {'message': message} : null,
        );

      case APIRequestStatus.failed:
        _onErrorCallbacks[key]?.call(message);
        // [HAZ-004] Hata sessiz geçmez
        MedLogger.warn(
          unit: 'SW-UNIT-UI',
          swreq: 'SWREQ-UI-MIXIN-001',
          message: '$notifierName.$key → failed',
          context: message != null ? {'message': message} : null,
        );

      case APIRequestStatus.initial:
        break;
    }
  }

  // ── execute — Result<T> dönen operasyonlar ────────────────────
  // [SWREQ-UI-MIXIN-002] [HAZ-004]

  Future<void> execute<T>(
    OperationKey key, {
    required Future<Result<T>> Function() operation,
    required void Function(T data) onData,
    void Function(AppException error)? onFailed,
    String? loadingMessage,
    String? successMessage,
    String swreq = 'SWREQ-UI-MIXIN-002',
  }) async {
    setLoading(key, message: loadingMessage);

    MedLogger.info(unit: 'SW-UNIT-UI', swreq: swreq, message: '$notifierName.$key başlatıldı');

    final response = await operation();

    response.when(
      ok: (data) {
        setSuccess(key, message: successMessage);
        onData(data);
      },
      error: (error) {
        // [HAZ-004] Hata her zaman loglanır, sessiz geçmez
        MedLogger.error(
          unit: 'SW-UNIT-UI',
          swreq: swreq,
          message: '$notifierName.$key hata',
          context: {
            'errorType': error.runtimeType.toString(),
            'message': error.message,
            'isRetryable': error.isRetryable,
          },
          error: error,
        );
        setFailed(key, message: error.userMessage);
        onFailed?.call(error);
      },
    );
  }

  // ── executeVoid — void dönüşlü operasyonlar ───────────────────
  // [SWREQ-UI-MIXIN-003] [HAZ-004]
  // NOT: Result<void> kullanır — manager'daki mevcut kodla uyumlu

  Future<void> executeVoid(
    OperationKey key, {
    required Future<Result<void>> Function() operation,
    void Function()? onSuccess,
    void Function(AppException error)? onFailed,
    String? loadingMessage,
    String? successMessage,
    String swreq = 'SWREQ-UI-MIXIN-003',
  }) async {
    setLoading(key, message: loadingMessage);

    MedLogger.info(unit: 'SW-UNIT-UI', swreq: swreq, message: '$notifierName.$key başlatıldı');

    final response = await operation();

    response.when(
      ok: (_) {
        setSuccess(key, message: successMessage);
        onSuccess?.call();
      },
      error: (error) {
        // [HAZ-004] Hata her zaman loglanır, sessiz geçmez
        MedLogger.error(
          unit: 'SW-UNIT-UI',
          swreq: swreq,
          message: '$notifierName.$key hata',
          context: {'errorType': error.runtimeType.toString(), 'message': error.message},
          error: error,
        );
        setFailed(key, message: error.userMessage);
        onFailed?.call(error);
      },
    );
  }

  // ── executeRepo — RepoResult<T> dönen operasyonlar ───────────────
  // [SWREQ-UI-MIXIN-004] [HAZ-004] [HAZ-007]

  Future<void> executeRepo<T>(
    OperationKey key, {
    required Future<RepoResult<T>> Function() operation,
    required void Function(T data) onData,
    void Function(T data, DateTime savedAt)? onStale,
    void Function(AppException error)? onFailed,
    String? loadingMessage,
    String? successMessage,
    String swreq = 'SWREQ-UI-MIXIN-004',
  }) async {
    setLoading(key, message: loadingMessage);

    MedLogger.info(unit: 'SW-UNIT-UI', swreq: swreq, message: '$notifierName.$key başlatıldı');

    final response = await operation();

    response.when(
      success: (data) {
        setSuccess(key, message: successMessage);
        onData(data);
      },
      stale: (data, savedAt) {
        // [HAZ-007] Stale veri — UI gösterir, banner açılabilir
        MedLogger.warn(
          unit: 'SW-UNIT-UI',
          swreq: swreq,
          message: '$notifierName.$key stale veri',
          context: {'savedAt': savedAt.toIso8601String()},
        );
        setSuccess(key, message: successMessage);
        onData(data);
        onStale?.call(data, savedAt);
      },
      failure: (error) {
        // [HAZ-004] Hata sessiz geçmez
        MedLogger.error(
          unit: 'SW-UNIT-UI',
          swreq: swreq,
          message: '$notifierName.$key hata',
          context: {
            'errorType': error.runtimeType.toString(),
            'message': error.message,
            'isRetryable': error.isRetryable,
          },
          error: error,
        );
        setFailed(key, message: error.userMessage);
        onFailed?.call(error);
      },
    );
  }
}
