// lib/feature/dashboard/domain/model/app_models.dart
//
// [SWREQ-UI-DASH-005]
// TopBar, SubNav ve sağ kolon widget'larının domain modelleri.

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
