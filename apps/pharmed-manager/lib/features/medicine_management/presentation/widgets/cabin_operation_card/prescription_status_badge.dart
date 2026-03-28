import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

/// Reçete durumunu renkli badge olarak gösterir.
/// item.status null ise render edilmez — widget çağrılmadan önce
/// null kontrolü yapılması önerilir.
class PrescriptionStatusBadge extends StatelessWidget {
  final PrescriptionStatus status;

  const PrescriptionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
