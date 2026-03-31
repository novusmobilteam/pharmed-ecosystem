// lib/features/setup_wizard/domain/model/scan_log_entry.dart
//
// [SWREQ-SETUP-UI-016] [IEC 62304 §5.5]
// Kabin tarama süreci log satırı modeli.
// Her adım UI'da ayrı bir satır olarak gösterilir.
// Sınıf: Class B

import 'package:equatable/equatable.dart';

/// Tek bir tarama log satırının durumu
enum ScanLogStatus {
  pending, // Spinner — işlem devam ediyor
  ok, // Yeşil checkmark — başarılı
  error, // Kırmızı X — hata
}

/// Tarama sürecinde bir adımı temsil eder.
///
/// - [message]  : Ana açıklama ("Yönetim kartı aranıyor…")
/// - [message]  : Başlıkta görünecek kısmi açıklama ("Yönetim kartı aranıyor…")
/// - [detail]   : Opsiyonel detay ("Adres: 1, Tip: Kübik 4×4")
/// - [status]   : Adımın mevcut durumu
class ScanLogEntry extends Equatable {
  const ScanLogEntry({required this.message, required this.status, this.detail, this.headerMessage});

  /// Pending (spinner) durumunda başlayan log satırı
  const ScanLogEntry.pending(String message, {String? headerMessage})
    : this(message: message, headerMessage: headerMessage ?? message, status: ScanLogStatus.pending);

  final String message;
  final String? headerMessage;
  final String? detail;
  final ScanLogStatus status;

  ScanLogEntry copyWith({String? message, String? detail, ScanLogStatus? status}) {
    return ScanLogEntry(message: message ?? this.message, detail: detail ?? this.detail, status: status ?? this.status);
  }

  ScanLogEntry asOk({String? detail}) => copyWith(status: ScanLogStatus.ok, detail: detail ?? this.detail);

  ScanLogEntry asError({String? detail}) => copyWith(status: ScanLogStatus.error, detail: detail ?? this.detail);

  @override
  List<Object?> get props => [message, detail, status];
}
