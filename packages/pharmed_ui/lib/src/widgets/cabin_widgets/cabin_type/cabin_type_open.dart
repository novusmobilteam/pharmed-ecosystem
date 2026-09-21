part of 'cabin_type_reference_view.dart';

class CabinTypeOpen extends StatelessWidget {
  const CabinTypeOpen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetMd,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MedColors.border,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.text3),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: 9,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              color: MedColors.surface,
              borderRadius: BorderRadius.circular(3.0),
              border: Border.all(color: MedColors.text4),
            ),
          );
        },
      ),
    );
  }
}
