part of 'cabin_type_reference_view.dart';

class CabinTypeFreezer extends StatelessWidget {
  const CabinTypeFreezer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetMd,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MedColors.blueLight2.withAlpha(20),
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.blue),
      ),
      child: Column(
        spacing: 8.0,
        children: [
          // Ekran
          Container(
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MedColors.surface,
              border: Border.all(color: MedColors.blue, width: 0.5),
              borderRadius: MedRadius.smAll,
            ),
            child: Icon(PhosphorIcons.snowflake(), color: MedColors.blue),
          ),
          // Body
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: MedColors.blue.withAlpha(30),
                border: Border.all(color: MedColors.blue, width: 0.5),
                borderRadius: MedRadius.smAll,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => Container(
                    height: 2,
                    margin: EdgeInsets.symmetric(horizontal: 12.0),
                    width: context.width,
                    decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.smAll),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
