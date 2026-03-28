// packages/pharmed_core/lib/src/repository/repo_result.dart
//
// [SWREQ-CORE-REPO-001]
// Tüm repository'lerin döndürdüğü sonuç tipi.
// Result<T>'den farklı olarak cache/stale senaryosunu da taşır.
// Sınıf: Class B

sealed class RepoResult<T> {
  const RepoResult();
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
  final Object error;
}
