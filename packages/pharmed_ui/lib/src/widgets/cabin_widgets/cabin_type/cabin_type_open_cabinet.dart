part of 'cabin_type_reference_view.dart';

class CabinTypeOpenCabinet extends StatelessWidget {
  const CabinTypeOpenCabinet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetMd,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.text3),
      ),
      child: Column(spacing: 4.0, children: List.generate(4, (index) => Expanded(child: _shelf(index)))),
    );
  }

  Widget _shelf(int index) {
    return Container(
      padding: EdgeInsets.only(left: 5.0, bottom: 2.0),
      margin: EdgeInsets.only(bottom: 4.0),
      decoration: BoxDecoration(
        color: MedColors.border.withAlpha(65),
        border: Border(bottom: BorderSide(color: MedColors.text2)),
      ),
      child: _CabinSkylineBars(seed: index),
    );
  }
}

class _CabinSkylineBars extends StatelessWidget {
  const _CabinSkylineBars({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    final random = Random(seed);
    final barCount = 2 + random.nextInt(4);

    return Row(
      spacing: 4.0,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(barCount, (index) {
        final height = 15.0 + random.nextInt(16);
        return Container(
          width: 13,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(25),
            borderRadius: BorderRadius.circular(2.0),
            border: Border.all(color: MedColors.border),
          ),
        );
      }),
    );
  }
}
