part of 'cabin_type_reference_view.dart';

/// Master kabin: üstte dokunmatik ekran, altında iki birim doz çekmece ve
/// en altta kübik (gözlü) büyük çekmece.
class CabinTypeMaster extends StatelessWidget {
  const CabinTypeMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return _CabinBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 3,
        children: [
          // Ekran
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: MedColors.text,
                borderRadius: MedRadius.smAll,
                border: Border.all(color: MedColors.text2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 2,
                children: [
                  FractionallySizedBox(widthFactor: 0.55, child: _bar(MedColors.blueLight2)),
                  FractionallySizedBox(widthFactor: 0.8, child: _bar(MedColors.text2)),
                  FractionallySizedBox(widthFactor: 0.4, child: _bar(MedColors.text2)),
                ],
              ),
            ),
          ),
          // Birim doz çekmeceler
          for (var i = 0; i < 2; i++)
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                decoration: _faceDecoration(),
                child: const _Handle(),
              ),
            ),
          // Kübik çekmece — gözler
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: _faceDecoration(),
              child: Column(
                spacing: 1.5,
                children: [
                  for (var r = 0; r < 3; r++)
                    Expanded(
                      child: Row(
                        spacing: 1.5,
                        children: [
                          for (var c = 0; c < 4; c++)
                            Expanded(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: MedColors.blueLight,
                                  borderRadius: BorderRadius.circular(1.5),
                                  border: Border.all(color: MedColors.blueMid, width: 0.6),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(Color color) => Container(
    height: 2,
    decoration: BoxDecoration(color: color, borderRadius: MedRadius.smAll),
  );
}
