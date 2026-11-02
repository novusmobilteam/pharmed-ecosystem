part of 'cabin_type_reference_view.dart';

/// Serum kabini: camlı kapı arkasında üç raf, raflarda serum torbaları
/// (avadanlıklar).
class CabinTypeSerum extends StatelessWidget {
  const CabinTypeSerum({super.key});

  /// Raf başına torba sayısı — üstten alta.
  static const _bagsPerShelf = [3, 2, 3];

  @override
  Widget build(BuildContext context) {
    return _CabinBody(
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: _faceDecoration(
          color: Color.alphaBlend(MedColors.blueLight.withAlpha(150), MedColors.surface),
          border: MedColors.blueMid,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final count in _bagsPerShelf) Expanded(child: _shelf(count))],
        ),
      ),
    );
  }

  Widget _shelf(int count) {
    return Container(
      padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.text3, width: 1.5)),
      ),
      child: Row(
        spacing: 3,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (var i = 0; i < count; i++) const Expanded(child: _SerumBag())],
      ),
    );
  }
}

/// Serum torbası: üstte asma halkası, gövde, altta port.
class _SerumBag extends StatelessWidget {
  const _SerumBag();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 4,
          height: 2,
          decoration: BoxDecoration(
            border: Border.all(color: MedColors.text3, width: 0.8),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: MedColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(2), bottom: Radius.circular(4)),
              border: Border.all(color: MedColors.blueLight2, width: 0.8),
            ),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: MedColors.blueLight2.withAlpha(70),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                ),
              ),
            ),
          ),
        ),
        Container(width: 2, height: 3, color: MedColors.text3),
      ],
    );
  }
}
