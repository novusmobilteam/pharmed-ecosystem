enum APIRequestStatus { initial, loading, success, failed }

extension APIRequestStatusExtension on APIRequestStatus {
  bool get isInitial => this == APIRequestStatus.initial;

  bool get isLoading => this == APIRequestStatus.loading;

  bool get isSuccess => this == APIRequestStatus.success;

  bool get isFailed => this == APIRequestStatus.failed;
}
