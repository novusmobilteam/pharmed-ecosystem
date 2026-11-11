import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';

/// Yönetim kartı adresi seçici (a–p). İstasyondaki kabinler adlarıyla gösterilir.
class AddressPicker extends ConsumerWidget {
  const AddressPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabins = ref.watch(sessionProvider.select((s) => s.cabins));
    return DropdownButton<int>(
      value: value,
      items: [
        for (var i = 1; i <= 16; i++)
          DropdownMenuItem(
            value: i,
            child: Text(
              cabinNameForAddress(cabins, i) == null ? addressLabel(i) : '${addressLabel(i)} — ${cabinNameForAddress(cabins, i)}',
            ),
          ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
