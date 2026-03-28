import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum _BadgeStatus { expired, critical, warning, normal }

class RemainingDayBadge extends StatelessWidget {
  const RemainingDayBadge({super.key, required this.days});

  final int days;

  _BadgeStatus get _status {
    if (days < 0) return _BadgeStatus.expired;
    if (days <= 7) return _BadgeStatus.critical;
    if (days <= 30) return _BadgeStatus.warning;
    return _BadgeStatus.normal;
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      _BadgeStatus.expired => _Badge(
          label: '${days.abs()}g geçti',
          icon: PhosphorIcons.warning(),
          color: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFECACA),
        ),
      _BadgeStatus.critical => _Badge(
          label: '$days gün',
          icon: PhosphorIcons.timer(),
          color: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFECACA),
        ),
      _BadgeStatus.warning => _Badge(
          label: '$days gün',
          icon: PhosphorIcons.hourglass(),
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
        ),
      _BadgeStatus.normal => _Badge(
          label: '$days gün',
          icon: PhosphorIcons.checkCircle(),
          color: const Color(0xFF059669),
          bgColor: const Color(0xFFECFDF5),
          borderColor: const Color(0xFFA7F3D0),
        ),
    };
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color color, bgColor, borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
