import 'package:pharmed_core/pharmed_core.dart';

class CachedEntry<T> {
  const CachedEntry({required this.data, required this.savedAt});

  final T data;
  final DateTime savedAt;

  /// [HAZ-007] maxAgeMinutes geçtiyse stale sayılır
  bool isStale(int maxAgeMinutes) {
    final age = DateTime.now().difference(savedAt).inMinutes;
    return age > maxAgeMinutes;
  }

  bool isExpired(Duration ttl) => DateTime.now().difference(savedAt) > ttl;

  Map<String, dynamic> toJson(Object? Function(T) dataSerializer) => {
    'data': dataSerializer(data),
    'savedAt': savedAt.toIso8601String(),
  };

  static CachedEntry<T> fromJson<T>(Map<dynamic, dynamic> json, T Function(dynamic) dataDeserializer) =>
      CachedEntry<T>(data: dataDeserializer(json['data']), savedAt: DateTime.parse(json['savedAt'] as String));

  static Future<RepoResult<T>> performFetch<T>({
    required CachedEntry<T>? currentCache,
    required Duration ttl,
    required bool forceRefresh,
    required Future<Result<T>> Function() fetcher,
    required void Function(CachedEntry<T>) onSaveCache,
  }) async {
    // 1. Cache geçerliyse hemen döndür
    if (!forceRefresh && currentCache != null && !currentCache.isExpired(ttl)) {
      return RepoSuccess(currentCache.data);
    }

    // 2. Yeni veriyi çek
    final result = await fetcher();

    return result.when(
      ok: (data) {
        final newEntry = CachedEntry(data: data, savedAt: DateTime.now());
        onSaveCache(newEntry);
        return RepoSuccess(data);
      },
      error: (error) {
        // 3. Hata durumunda cache varsa 'Stale' döndür, yoksa Failure
        if (currentCache != null) {
          return RepoStale(currentCache.data, currentCache.savedAt);
        }
        return RepoFailure(error);
      },
    );
  }
}
