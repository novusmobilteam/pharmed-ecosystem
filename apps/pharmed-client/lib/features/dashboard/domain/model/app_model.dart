// lib/feature/dashboard/domain/model/app_models.dart
//
// [SWREQ-UI-DASH-005]
// TopBar, SubNav ve sağ kolon widget'larının domain modelleri.

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// AppUser — oturum açmış kullanıcı
// ─────────────────────────────────────────────────────────────────

class AppUser extends Equatable {
  const AppUser({required this.username, required this.fullName, required this.role});

  final String username;
  final String fullName;
  final String role;

  /// "Ayşe Kara" → "AK"
  String get initials => fullName.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();

  @override
  List<Object?> get props => [username];
}

// ─────────────────────────────────────────────────────────────────
// MenuItem — alt navigasyon çubuğu öğesi
// Şimdilik statik — ileride MenuDataSource'tan beslenecek
// ─────────────────────────────────────────────────────────────────

class MenuItem extends Equatable {
  const MenuItem({
    required this.id,
    required this.label,
    required this.icon,
    this.requiresAuth = true,
    this.isActive = false,
  });

  final String id;
  final String label;
  final IconData icon;

  /// true → giriş yapılmamışsa kilitli görünür
  final bool requiresAuth;
  final bool isActive;

  MenuItem copyWith({bool? isActive}) =>
      MenuItem(id: id, label: label, icon: icon, requiresAuth: requiresAuth, isActive: isActive ?? this.isActive);

  @override
  List<Object?> get props => [id, isActive];
}

// Varsayılan menü listesi
// [SWREQ-UI-DASH-005] Şimdilik statik. MenuDataSource entegrasyonu
// eklendiğinde DI üzerinden beslenecek, bu liste fallback olarak kalacak.
final kDefaultMenuItems = [
  const MenuItem(
    id: 'dashboard',
    label: 'Dashboard',
    icon: Icons.grid_view_rounded,
    requiresAuth: false,
    isActive: true,
  ),
  const MenuItem(id: 'cabin', label: 'Kabin Yönetimi', icon: Icons.lock_outline_rounded, requiresAuth: true),
  const MenuItem(id: 'patients', label: 'Hasta Listesi', icon: Icons.people_outline_rounded, requiresAuth: true),
  const MenuItem(id: 'stock', label: 'Stok Takibi', icon: Icons.inventory_2_outlined, requiresAuth: true),
];

// ─────────────────────────────────────────────────────────────────
// AlertItem — uyarı listesi öğesi
// ─────────────────────────────────────────────────────────────────

enum AlertSeverity { critical, warning, info }

class AlertItem extends Equatable {
  const AlertItem({required this.id, required this.message, required this.time, required this.severity, this.detail});

  final String id;
  final String message;
  final String time;
  final AlertSeverity severity;
  final String? detail;

  @override
  List<Object?> get props => [id];
}

// ─────────────────────────────────────────────────────────────────
// ActivityItem — son aktiviteler
// ─────────────────────────────────────────────────────────────────

enum ActivityType { distribution, cabinOpen, prescription, return_, fill }

class ActivityItem extends Equatable {
  const ActivityItem({required this.id, required this.message, required this.meta, required this.type});

  final String id;
  final String message;

  /// Örn: "08:41 · AK"
  final String meta;
  final ActivityType type;

  @override
  List<Object?> get props => [id];
}

// ─────────────────────────────────────────────────────────────────
// QuickAction — hızlı işlemler
// ─────────────────────────────────────────────────────────────────

class QuickAction extends Equatable {
  const QuickAction({required this.id, required this.label, required this.icon, required this.requiresAuth});

  final String id;
  final String label;
  final IconData icon;
  final bool requiresAuth;

  @override
  List<Object?> get props => [id];
}

final kDefaultQuickActions = [
  const QuickAction(id: 'prescription', label: 'Reçete Gir', icon: Icons.note_add_outlined, requiresAuth: true),
  const QuickAction(id: 'return', label: 'İade Al', icon: Icons.replay_rounded, requiresAuth: true),
  const QuickAction(id: 'report', label: 'Rapor Al', icon: Icons.bar_chart_rounded, requiresAuth: true),
  const QuickAction(id: 'count', label: 'Stok Say', icon: Icons.fact_check_outlined, requiresAuth: true),
];
