// [SWREQ-CORE-REPO-001] [IEC 62304 §5.5]
// Tüm repository'lerin döndürdüğü sonuç tipi.
// Result<T>'den farklı olarak cache/stale senaryosunu da taşır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

sealed class RepoResult<T> {
  const RepoResult();

  /// Duruma göre ilgili callback'i çalıştırır.
  ///
  /// ```dart
  /// final result = await repository.getCabins();
  /// result.when(
  ///   success: (cabins) => ...,
  ///   stale:   (cabins, savedAt) => ...,
  ///   failure: (error) => ...,
  /// );
  /// ```
  R when<R>({
    required R Function(T data) success,
    required R Function(T data, DateTime savedAt) stale,
    required R Function(AppException error) failure,
  }) {
    return switch (this) {
      RepoSuccess<T>(:final data) => success(data),
      RepoStale<T>(:final data, :final savedAt) => stale(data, savedAt),
      RepoFailure<T>(:final error) => failure(error),
    };
  }

  /// Başarılı veya stale durumda veriyi döner, failure'da null döner.
  T? get dataOrNull => switch (this) {
    RepoSuccess<T>(:final data) => data,
    RepoStale<T>(:final data) => data,
    RepoFailure<T>() => null,
  };

  /// Sadece tam başarı durumunu kontrol eder.
  bool get isSuccess => this is RepoSuccess<T>;

  /// Stale (eski cache) durumunu kontrol eder.
  bool get isStale => this is RepoStale<T>;

  /// Failure durumunu kontrol eder.
  bool get isFailure => this is RepoFailure<T>;

  /// Başarılı veya stale — kullanılabilir veri var mı?
  bool get hasData => this is RepoSuccess<T> || this is RepoStale<T>;
}

/// Servis başarılı yanıt verdi.
final class RepoSuccess<T> extends RepoResult<T> {
  const RepoSuccess(this.data);
  final T data;
}

/// [HAZ-007] Servis başarısız ama geçerli (fresh) cache var.
/// UI gösterir + StaleBanner açar.
final class RepoStale<T> extends RepoResult<T> {
  const RepoStale(this.data, this.savedAt);
  final T data;
  final DateTime savedAt;
}

/// Servis başarısız ve kullanılabilir cache yok.
final class RepoFailure<T> extends RepoResult<T> {
  const RepoFailure(this.error);
  final AppException error;
}
