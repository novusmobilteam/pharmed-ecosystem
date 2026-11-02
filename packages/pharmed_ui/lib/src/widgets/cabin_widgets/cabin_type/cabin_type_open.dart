part of 'cabin_type_reference_view.dart';

/// Açık kabin: 3×4 açık bölme (göz); her bölmenin önünde etiket şeridi.
class CabinTypeOpen extends StatelessWidget {
  const CabinTypeOpen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CabinBody(
      child: Column(
        spacing: 2,
        children: [
          for (var r = 0; r < 4; r++)
            Expanded(
              child: Row(
                spacing: 2,
                children: [for (var c = 0; c < 3; c++) Expanded(child: _bin())],
              ),
            ),
        ],
      ),
    );
  }

  Widget _bin() {
    return Container(
      decoration: _faceDecoration(color: MedColors.surface2),
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        widthFactor: 0.7,
        heightFactor: 0.28,
        child: DecoratedBox(
          decoration: BoxDecoration(color: MedColors.blueMid, borderRadius: BorderRadius.circular(1)),
        ),
      ),
    );
  }
}
