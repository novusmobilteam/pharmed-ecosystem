part of 'cabin_type_reference_view.dart';

/// Açık dolap: kapısız, dört raf; raflarda farklı boyda kutular.
class CabinTypeOpenCabinet extends StatelessWidget {
  const CabinTypeOpenCabinet({super.key});

  @override
  Widget build(BuildContext context) {
    return _CabinBody(
      child: Container(
        decoration: _faceDecoration(color: MedColors.surface2),
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (var i = 0; i < 4; i++) Expanded(child: _shelf(i))],
        ),
      ),
    );
  }

  Widget _shelf(int index) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.cabinBorder, width: 1.5)),
      ),
      child: _ShelfBoxes(seed: index),
    );
  }
}

/// Rafa dizilmiş kutular — [seed] ile her rafta farklı ama sabit bir dizilim.
class _ShelfBoxes extends StatelessWidget {
  const _ShelfBoxes({required this.seed});

  final int seed;

  static const _colors = [MedColors.blueLight, MedColors.greenLight, MedColors.amberLight];
  static const _borders = [MedColors.blueMid, MedColors.green, MedColors.amberBorder];

  @override
  Widget build(BuildContext context) {
    final random = Random(seed * 7 + 3);
    final count = 2 + random.nextInt(3);

    return Row(
      spacing: 2,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < count; i++)
          Expanded(
            flex: 2 + random.nextInt(3),
            child: FractionallySizedBox(
              heightFactor: 0.45 + random.nextDouble() * 0.5,
              child: () {
                final c = random.nextInt(_colors.length);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: _colors[c],
                    borderRadius: BorderRadius.circular(1.5),
                    border: Border.all(color: _borders[c].withAlpha(160), width: 0.6),
                  ),
                );
              }(),
            ),
          ),
        const Spacer(),
      ],
    );
  }
}
