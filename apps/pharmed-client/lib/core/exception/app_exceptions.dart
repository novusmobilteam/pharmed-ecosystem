// lib/core/exception/app_exceptions.dart
//
// [SWREQ-CORE-EX-001]
// Proje genelinde kullanılan exception hiyerarşisi.
// Tüm exception'lar AppException'dan türer.
// Her exception MedLogger ile loglanmalıdır.

// ─────────────────────────────────────────────────────────────────
// Temel sınıf
// ─────────────────────────────────────────────────────────────────

sealed class AppException implements Exception {
  const AppException({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '${runtimeType}: $message';
}

// ─────────────────────────────────────────────────────────────────
// Ağ / Servis exception'ları
// ─────────────────────────────────────────────────────────────────

/// Ağa hiç ulaşılamadı — WiFi yok, DNS çözümlenemiyor
final class NetworkUnavailableException extends AppException {
  const NetworkUnavailableException({required super.message, super.cause});
}

final class SerialPortException extends AppException {
  SerialPortException({required super.message});
}

/// Sunucu yanıt verdi ama beklenen dışı HTTP kodu döndü
final class ServiceException extends AppException {
  const ServiceException({required super.message, required this.statusCode, this.traceId, super.cause});

  final int statusCode;

  /// Sunucu tarafında iz bırakmak için — log'a yazılır
  final String? traceId;
}

/// Servis yanıt vermedi (timeout)
final class TimeoutException extends AppException {
  const TimeoutException({required super.message, super.cause});
}

/// Servis yanıtı beklenen JSON formatında değil
final class MalformedDataException extends AppException {
  const MalformedDataException({
    required super.message,

    /// Log için saklanır, UI'a gösterilmez
    this.rawData,
    super.cause,
  });

  final String? rawData;
}

/// Servis boş yanıt döndürdü (200 ama body null/empty)
final class EmptyResponseException extends AppException {
  const EmptyResponseException({required super.message, super.cause});
}

// ─────────────────────────────────────────────────────────────────
// Validasyon exception'ları
// ─────────────────────────────────────────────────────────────────

/// Input validasyonu başarısız — datasource girişinde
final class ValidationException extends AppException {
  const ValidationException({required super.message, this.field, this.value, super.cause});

  /// Hangi alan hatalı: "cabinId", "medicineId"
  final String? field;

  /// Hatalı değer (log için)
  final Object? value;
}

// ─────────────────────────────────────────────────────────────────
// Mapping exception'ları
// ─────────────────────────────────────────────────────────────────

/// DTO → Domain dönüşümü başarısız
/// [HAZ-003] Hatalı mapping yanlış veri gösterimine yol açar
final class MappingException extends AppException {
  const MappingException({required super.message, this.dto, super.cause});

  /// Hatalı DTO (log için saklanır, UI'a gösterilmez)
  final Map<String, dynamic>? dto;
}

// ─────────────────────────────────────────────────────────────────
// Cache exception'ları
// ─────────────────────────────────────────────────────────────────

/// Cache okuması/yazması başarısız
final class CacheException extends AppException {
  const CacheException({required super.message, this.boxName, this.key, super.cause});

  final String? boxName;
  final String? key;
}

/// Cache verisi mevcut ama çok eski — kullanılamaz
/// [HAZ-007] Çok eski cache göstermek daha tehlikeli
final class StaleCacheException extends AppException {
  const StaleCacheException({required super.message, required this.savedAt, required this.maxAgeMinutes, super.cause});

  final DateTime savedAt;
  final int maxAgeMinutes;
}

// ─────────────────────────────────────────────────────────────────
// İş kuralı exception'ları
// ─────────────────────────────────────────────────────────────────

/// Domain iş kuralı ihlali
/// Örn: dolum miktarı kabin kapasitesini aşıyor
final class BusinessRuleException extends AppException {
  const BusinessRuleException({required super.message, required this.ruleCode, super.cause});

  /// İzlenebilirlik için kural kodu: "FILL_CAPACITY_EXCEEDED"
  final String ruleCode;
}

/// Kayıt bulunamadı — ilaç atanmamış, çekmece boş vb.
/// Hata değil, beklenen "yok" durumu — UI buna göre davranır.
final class NotFoundException extends AppException {
  const NotFoundException({required super.message, this.id, this.resourceType});

  /// Aranan kayıt ID'si (log için)
  final int? id;

  /// Örn: "CabinStock", "Medicine"
  final String? resourceType;
}

final class UnexpectedException extends AppException {
  const UnexpectedException({super.message = 'Beklenmeyen bir hata oluştu', super.cause});
}

// ─────────────────────────────────────────────────────────────────
// Exception'dan kullanıcıya gösterilecek mesaj türet
// UI katmanı bu metodu kullanır, exception string'ini değil
// ─────────────────────────────────────────────────────────────────

extension AppExceptionUiMessage on AppException {
  String get userMessage {
    return switch (this) {
      NetworkUnavailableException() => 'Sunucuya bağlanılamıyor. Ağ bağlantınızı kontrol edin.',
      TimeoutException() => 'Sunucu yanıt vermedi. Lütfen tekrar deneyin.',
      ServiceException(:final statusCode) =>
        statusCode >= 500
            ? 'Sunucu hatası ($statusCode). Lütfen tekrar deneyin.'
            : 'İşlem tamamlanamadı ($statusCode).',
      MalformedDataException() => 'Sunucudan beklenmedik veri alındı.',
      EmptyResponseException() => 'Sunucu boş yanıt döndürdü.',
      ValidationException(:final field) => field != null ? '$field alanı geçersiz.' : 'Girilen bilgiler geçersiz.',
      MappingException() => 'Veri işlenirken hata oluştu.',
      CacheException() => 'Yerel veri okunamadı.',
      StaleCacheException() => 'Güncel veriye ulaşılamıyor. Lütfen bağlantıyı kontrol edin.',
      BusinessRuleException(:final message) => message,
      NotFoundException(:final resourceType) =>
        resourceType != null ? '$resourceType bulunamadı.' : 'Kayıt bulunamadı.',
      UnexpectedException() => 'Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.',
      SerialPortException() => 'Seri porta bağlanılamadı. Lütfen teknik servis ile iletişime geçiniz.',
    };
  }

  /// true → yeniden deneme butonu gösterilsin
  bool get isRetryable {
    return switch (this) {
      NetworkUnavailableException() => true,
      TimeoutException() => true,
      ServiceException(:final statusCode) => statusCode >= 500,
      _ => false,
    };
  }
}
