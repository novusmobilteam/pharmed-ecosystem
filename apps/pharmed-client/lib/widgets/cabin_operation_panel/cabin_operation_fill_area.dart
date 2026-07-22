// Master kabin işlem ekranlarının ortak form sarmalayıcısı: genişliğe göre
// ortalanmış alan, kayıt sırasında (isSaving) kilitlenme, altta footer
// (onay butonu vb.) slotu. MasterRefillExecutionPanel'deki _FillForm'un
// generic hali — [maxWidth] hesaplaması (grid'e göre dar/geniş) dolum'a
// özel bir karar olduğu için BİLEREK dışarıdan alınıyor, burada hesaplanmıyor.

import 'package:flutter/material.dart';

class CabinOperationFillArea extends StatelessWidget {
  const CabinOperationFillArea({
    super.key,
    required this.maxWidth,
    required this.isLocked,
    required this.content,
    required this.footer,
  });

  final double maxWidth;

  /// Kayıt/işlem sürerken (ör. isSaving) true — içerik kilitlenir, footer
  /// kilitlenmez (footer kendi loading/disabled durumunu kendi yönetir).
  final bool isLocked;

  final Widget content;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Opacity(
                opacity: isLocked ? 0.55 : 1.0,
                child: IgnorePointer(ignoring: isLocked, child: content),
              ),
            ),
            const SizedBox(height: 18),
            footer,
          ],
        ),
      ),
    );
  }
}
