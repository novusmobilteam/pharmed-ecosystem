import 'package:pharmed_ui/pharmed_ui.dart';

enum ParityBit {
  none(id: 1),
  even(id: 2),
  odd(id: 3);

  const ParityBit({required this.id});

  final int id;

  String get label {
    switch (this) {
      case ParityBit.none:
        return contextlessL10n().enumCore_parityBitNone;
      case ParityBit.even:
        return contextlessL10n().enumCore_parityBitEven;
      case ParityBit.odd:
        return contextlessL10n().enumCore_parityBitOdd;
    }
  }

  static ParityBit? fromId(int? id) {
    return ParityBit.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ParityBit.none,
    );
  }
}
