// [SWREQ-FP-100]
// Parmak pozisyonu — ISO/IEC 19794-2 "finger position" kodları.
// Kodlar servis sözleşmesinde ve şablonun içinde aynıdır; değiştirilmemelidir.
//
// Sınıf: Class B

enum FingerHand { right, left }

enum FingerPosition {
  rightThumb(1, FingerHand.right),
  rightIndex(2, FingerHand.right),
  rightMiddle(3, FingerHand.right),
  rightRing(4, FingerHand.right),
  rightLittle(5, FingerHand.right),
  leftThumb(6, FingerHand.left),
  leftIndex(7, FingerHand.left),
  leftMiddle(8, FingerHand.left),
  leftRing(9, FingerHand.left),
  leftLittle(10, FingerHand.left);

  const FingerPosition(this.isoCode, this.hand);

  /// ISO/IEC 19794-2 parmak pozisyon kodu (1–10).
  final int isoCode;
  final FingerHand hand;

  bool get isThumb => this == rightThumb || this == leftThumb;

  static FingerPosition? fromIsoCode(int? code) {
    for (final p in values) {
      if (p.isoCode == code) return p;
    }
    return null;
  }
}
