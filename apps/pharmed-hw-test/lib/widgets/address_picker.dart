import 'package:flutter/material.dart';

import '../core/providers.dart';

/// Yönetim kartı adresi seçici (a–p).
class AddressPicker extends StatelessWidget {
  const AddressPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: value,
      items: [for (var i = 1; i <= 16; i++) DropdownMenuItem(value: i, child: Text(addressLabel(i)))],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
