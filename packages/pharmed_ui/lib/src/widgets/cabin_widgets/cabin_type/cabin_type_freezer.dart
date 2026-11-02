part of 'cabin_type_reference_view.dart';

/// Buzdolabı: mavi tonlu gövde, üstte sıcaklık göstergesi, tek kapı ve
/// dikey kol.
class CabinTypeFreezer extends StatelessWidget {
  const CabinTypeFreezer({super.key});

  @override
  Widget build(BuildContext context) {
    return _CabinBody(
      tint: MedColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 3,
        children: [
          // Sıcaklık göstergesi
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: MedColors.text,
                borderRadius: MedRadius.smAll,
                border: Border.all(color: MedColors.blueDark, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 3,
                children: [
                  Icon(PhosphorIcons.snowflake(), size: 9, color: MedColors.blueLight2),
                  Flexible(
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(color: MedColors.blueLight2, borderRadius: MedRadius.smAll),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Kapı
          Expanded(
            flex: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.centerRight,
              decoration: _faceDecoration(
                color: Color.alphaBlend(MedColors.blue.withAlpha(18), MedColors.surface),
                border: MedColors.blueMid,
              ),
              child: const _Handle(vertical: true, color: MedColors.blueLight2),
            ),
          ),
        ],
      ),
    );
  }
}
