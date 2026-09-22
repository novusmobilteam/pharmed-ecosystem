part of 'cabin_type_reference_view.dart';

class CabinTypeSerum extends StatelessWidget {
  const CabinTypeSerum({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: MedSpacing.insetMd,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.text3),
      ),
      child: Column(
        spacing: 4.0,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (outIndex) {
          int count = outIndex % 2 == 0 ? 3 : 2;

          return Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: MedColors.text4, width: 2)),
            ),
            child: Row(
              spacing: 16.0,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(count, (index) {
                return Container(
                  margin: EdgeInsets.only(top: 3.0),
                  height: 30,
                  width: 22,
                  decoration: BoxDecoration(
                    color: MedColors.blueLight,
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(color: MedColors.text4),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
