part of 'cabin_type_reference_view.dart';

/// Kilitli dolap: üstte durum paneli, altında iki kanatlı kapı.
class CabinTypeCabinet extends StatelessWidget {
  const CabinTypeCabinet({super.key});

  @override
  Widget build(BuildContext context) {
    return _CabinBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 3,
        children: [
          // Durum paneli — kilit + LED
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: _faceDecoration(color: MedColors.surface2),
              child: Row(
                children: [
                  Icon(PhosphorIcons.lock(), size: 9, color: MedColors.text3),
                  const Spacer(),
                  const _Led(),
                ],
              ),
            ),
          ),
          // Kapılar
          Expanded(
            flex: 14,
            child: Row(
              spacing: 2,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _door(Alignment.centerRight)),
                Expanded(child: _door(Alignment.centerLeft)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _door(Alignment handleSide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      alignment: handleSide,
      decoration: _faceDecoration(),
      child: const _Handle(vertical: true),
    );
  }
}
