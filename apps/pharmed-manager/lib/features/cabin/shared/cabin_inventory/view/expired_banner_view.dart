import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/core.dart';

class ExpiredBannerView extends StatelessWidget {
  const ExpiredBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.warningCircle(), color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Miadı geçmiş stok mevcut. İşlem yapabilmek için önce boşaltma yapınız.',
              style: context.textTheme.bodySmall?.copyWith(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }
}
