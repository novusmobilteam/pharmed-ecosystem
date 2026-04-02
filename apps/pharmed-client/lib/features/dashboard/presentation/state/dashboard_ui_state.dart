// [SWREQ-UI-DASH-002] [IEC 62304 §5.5]
// Anasayfa UiState tanımı.
// Her durum açık ve ayrıştırılmış — belirsizlik yok.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

import '../../domain/model/dasboard_data.dart';

// ─────────────────────────────────────────────────────────────────
// DashboardSection — hangi bölümün hatalı olduğunu belirtir
// ─────────────────────────────────────────────────────────────────

enum DashboardSection { kpi, cabin, skt, treatments, menu }

sealed class DashboardUiState {
  const DashboardUiState();
}

/// İlk yükleme
final class DashboardLoading extends DashboardUiState {
  const DashboardLoading();
}

/// Veriler başarıyla yüklendi
final class DashboardLoaded extends DashboardUiState {
  const DashboardLoaded(this.data, {this.menuTree, this.flattenedMenus, this.failedSections});

  final DashboardData data;
  final List<MenuItem>? menuTree;
  final List<MenuItem>? flattenedMenus;
  final List<DashboardSection>? failedSections;

  DashboardLoaded copyWith({
    DashboardData? data,
    List<MenuItem>? menuTree,
    List<MenuItem>? flattenedMenus,
    List<DashboardSection>? failedSections,
  }) {
    return DashboardLoaded(
      data ?? this.data,
      menuTree: menuTree ?? this.menuTree,
      flattenedMenus: flattenedMenus ?? this.flattenedMenus,
      failedSections: failedSections ?? this.failedSections,
    );
  }
}

/// [HAZ-007] Servis çöktü, cache'den eski veri gösteriliyor
/// Kullanıcı uyarılmalı, bazı aksiyonlar kısıtlanabilir
final class DashboardStale extends DashboardUiState {
  const DashboardStale({
    required this.data,
    required this.staleSince,
    required this.canProceed,
    this.menuTree,
    this.flattenedMenus,
    this.failedSections,
  });

  final DashboardData data;
  final DateTime staleSince;

  /// [HAZ-009] false → kritik aksiyonlar disabled
  final bool canProceed;
  final List<MenuItem>? menuTree;
  final List<MenuItem>? flattenedMenus;
  final List<DashboardSection>? failedSections;

  DashboardStale copyWith({
    DashboardData? data,
    DateTime? staleSince,
    bool? canProceed,
    List<MenuItem>? menuTree,
    List<MenuItem>? flattenedMenus,
    List<DashboardSection>? failedSections,
  }) {
    return DashboardStale(
      data: data ?? this.data,
      staleSince: staleSince ?? this.staleSince,
      canProceed: canProceed ?? this.canProceed,
      menuTree: menuTree ?? this.menuTree,
      flattenedMenus: flattenedMenus ?? this.flattenedMenus,
      failedSections: failedSections ?? this.failedSections,
    );
  }
}

/// Kısmi yükleme hatası — bazı widget'lar yüklenemedi
/// Yüklenebilen kısımlar gösterilir, hatalı kısımlar error widget ile
final class DashboardPartial extends DashboardUiState {
  const DashboardPartial({required this.data, required this.failedSections, this.menuTree, this.flattenedMenus});

  final DashboardData data;
  final List<DashboardSection> failedSections;
  final List<MenuItem>? menuTree;
  final List<MenuItem>? flattenedMenus;

  DashboardPartial copyWith({
    DashboardData? data,
    List<DashboardSection>? failedSections,
    List<MenuItem>? menuTree,
    List<MenuItem>? flattenedMenus,
  }) {
    return DashboardPartial(
      data: data ?? this.data,
      failedSections: failedSections ?? this.failedSections,
      menuTree: menuTree ?? this.menuTree,
      flattenedMenus: flattenedMenus ?? this.flattenedMenus,
    );
  }
}

/// Hiçbir veri yüklenemedi
final class DashboardError extends DashboardUiState {
  const DashboardError({required this.message, required this.isRetryable});

  final String message;
  final bool isRetryable;
}
