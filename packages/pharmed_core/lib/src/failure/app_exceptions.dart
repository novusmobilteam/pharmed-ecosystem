// [SWREQ-CORE-EX-001]
// Proje genelinde kullanılan exception hiyerarşisi.
// Tüm exception'lar AppException'dan türer.
// Her exception MedLogger ile loglanmalıdır.

import 'package:pharmed_ui/pharmed_ui.dart';

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

final class CustomException extends AppException {
  CustomException({required super.message});
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

/// Servis tarafından dönen kontrol uyarısı.
/// İşlem devam ettirilebilir niteliktedir — kullanıcıya gösterilerek
/// onayı alındıktan sonra ilgili operasyon yeniden çalıştırılır.
final class CheckException extends AppException {
  const CheckException({required super.message, super.cause});
}

// ─────────────────────────────────────────────────────────────────
// Exception'dan kullanıcıya gösterilecek mesaj türet
// UI katmanı bu metodu kullanır, exception string'ini değil
// ─────────────────────────────────────────────────────────────────

extension AppExceptionUiMessage on AppException {
  String get userMessage {
    return switch (this) {
      NetworkUnavailableException() => contextlessL10n().appException_networkUnavailable,
      TimeoutException() => contextlessL10n().appException_timeout,
      ServiceException(:final statusCode) =>
        statusCode >= 500
            ? contextlessL10n().appException_serviceError5xx(statusCode)
            : contextlessL10n().appException_serviceErrorOther(statusCode),
      MalformedDataException() => contextlessL10n().appException_malformedData,
      EmptyResponseException() => contextlessL10n().appException_emptyResponse,
      ValidationException(:final field) =>
        field != null ? contextlessL10n().appException_validationField(field) : contextlessL10n().appException_validationGeneric,
      MappingException() => contextlessL10n().appException_mapping,
      CacheException() => contextlessL10n().appException_cache,
      StaleCacheException() => contextlessL10n().appException_staleCache,
      BusinessRuleException(:final message) => message,
      NotFoundException(:final resourceType) =>
        resourceType != null
            ? contextlessL10n().appException_notFoundWithType(resourceType)
            : contextlessL10n().appException_notFoundGeneric,
      UnexpectedException() => contextlessL10n().appException_unexpected,
      SerialPortException() => contextlessL10n().appException_serialPort,
      CustomException() => contextlessL10n().appException_custom,
      CheckException(:final message) => message,
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
