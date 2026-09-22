part of 'cabin_type_reference_view.dart';

class CabinTypeCabinet extends StatelessWidget {
  const CabinTypeCabinet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetMd,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MedColors.border2,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.text3),
      ),
      child: Column(
        spacing: 4.0,
        children: [
          // Ekran
          Container(
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MedColors.surface2,
              borderRadius: MedRadius.smAll,
              border: Border.all(color: MedColors.border),
            ),
          ),
          // Body
          Expanded(
            child: Row(
              spacing: 4.0,
              children: [
                Expanded(child: _doorView(Alignment.centerRight)),
                Expanded(child: _doorView(Alignment.centerLeft)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doorView(AlignmentGeometry alignment) {
    return Container(
      alignment: alignment,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Container(
        width: 4,
        height: 30,
        margin: EdgeInsets.all(4.0),
        decoration: BoxDecoration(color: MedColors.text3, borderRadius: MedRadius.smAll),
      ),
    );
  }
}
