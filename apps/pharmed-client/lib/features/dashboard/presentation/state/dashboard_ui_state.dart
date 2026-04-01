// [SWREQ-UI-DASH-002] [IEC 62304 §5.5]
// Anasayfa UiState tanımı.
// Her durum açık ve ayrıştırılmış — belirsizlik yok.
// Sınıf: Class B

import '../../domain/model/dasboard_data.dart';

sealed class DashboardUiState {
  const DashboardUiState();
}

/// İlk yükleme
final class DashboardLoading extends DashboardUiState {
  const DashboardLoading();
}

/// Veriler başarıyla yüklendi
final class DashboardLoaded extends DashboardUiState {
  const DashboardLoaded(this.data);
  final DashboardData data;
}

/// [HAZ-007] Servis çöktü, cache'den eski veri gösteriliyor
/// Kullanıcı uyarılmalı, bazı aksiyonlar kısıtlanabilir
final class DashboardStale extends DashboardUiState {
  const DashboardStale({required this.data, required this.staleSince, required this.canProceed});

  final DashboardData data;

  /// Cache'in kaydedildiği zaman
  final DateTime staleSince;

  /// [HAZ-009] false → kritik aksiyonlar disabled
  final bool canProceed;
}

/// Kısmi yükleme hatası — bazı widget'lar yüklenemedi
/// Yüklenebilen kısımlar gösterilir, hatalı kısımlar error widget ile
final class DashboardPartial extends DashboardUiState {
  const DashboardPartial({required this.data, required this.failedSections});

  final DashboardData data;
  final List<DashboardSection> failedSections;
}

/// Hiçbir veri yüklenemedi
final class DashboardError extends DashboardUiState {
  const DashboardError({required this.message, required this.isRetryable});

  final String message;
  final bool isRetryable;
}

// ─────────────────────────────────────────────────────────────────
// DashboardSection — hangi bölümün hatalı olduğunu belirtir
// ─────────────────────────────────────────────────────────────────

enum DashboardSection { kpi, cabin, skt, treatments }
