// [SWREQ-UI-VALUECARD-001] [IEC 62304 §5.5]
// Tıklanabilir "değer kartı": bir etiket + büyük değer gösterir, dokununca
// çağıran katman bir giriş yöntemi açar (numpad, tarih seçici vb.). Kartın
// kendisi giriş yöntemini bilmez — yalnızca görünüm + onTap.
//
// Opsiyonel trailing ikon (ör. takvim) tarih/özel alanları işaret eder.
// hasError=true kenarı amber yapar (zorunlu alan boş vb.).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum MedValueCardDensity { comfortable, compact }

class MedValueCard extends StatelessWidget {
  const MedValueCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailingIcon,
    this.hasError = false,
    this.placeholder = false,
    this.density = MedValueCardDensity.comfortable,
  });

  /// Üstteki küçük etiket (ör. "Sayım", "Son Kullanma").
  final String label;

  /// Büyük değer metni. Boşsa [placeholder] true verilerek soluk gösterilir.
  final String value;

  final VoidCallback onTap;

  /// Sağda gösterilecek opsiyonel ikon (ör. takvim).
  final IconData? trailingIcon;

  /// Zorunlu alan boş / geçersiz → amber kenar.
  final bool hasError;

  /// Değer henüz girilmemiş → değeri soluk (text3) göster.
  final bool placeholder;

  final MedValueCardDensity density;

  bool get _isCompact => density == MedValueCardDensity.compact;

  @override
  Widget build(BuildContext context) {
    final valueStyle = _isCompact
        ? MedTextStyles.numericLg(color: placeholder ? MedColors.text3 : MedColors.text)
        : MedTextStyles.numericXl(color: placeholder ? MedColors.text3 : MedColors.text);

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.lgAll,
      child: Container(
        padding: _isCompact ? MedSpacing.insetMd : MedSpacing.insetLg,
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: hasError ? MedColors.amber : MedColors.border),
          borderRadius: MedRadius.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: _isCompact ? 2 : 6,
          children: [
            Text(label, style: MedTextStyles.bodySm(color: MedColors.text3)),
            Row(
              children: [
                Expanded(
                  child: Text(value, style: valueStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 6),
                  Icon(trailingIcon, size: _isCompact ? 16 : 18, color: MedColors.text3),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
