// Master kabin işlem ekranlarının sol/sağ yerleşimi: sol tarafta opsiyonel
// CabinLocationGuide, sağda asıl içerik (açılma bekleme ekranı ya da form).
//
// [locationGuide] null verilirse hiç render edilmez (Row'a hiç girmez) —
// widget'ın kendisi INŞA EDİLMEDEN önce çağıran karar verir, yani
// gösterilmeyecekse CabinLocationGuide'ın toLocationItems() gibi
// hesaplamaları da hiç çalışmaz.

import 'package:flutter/material.dart';

class CabinOperationBody extends StatelessWidget {
  const CabinOperationBody({super.key, this.locationGuide, required this.child});

  /// Sol sütun, sabit 300px. null → gizli, sağ taraf tam genişlik kaplar.
  final Widget? locationGuide;

  /// Sağ taraf: açılma bekleme ekranı ya da form.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final guide = locationGuide;
    if (guide == null) return child;

    return Row(
      children: [
        SizedBox(width: 300, child: guide),
        const SizedBox(width: 20),
        Expanded(child: child),
      ],
    );
  }
}
