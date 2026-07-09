import 'package:pharmed_ui/pharmed_ui.dart';

enum DrugOp {
  pull, // İlaç Çeker
  fill, // Dolum
  returnOp, // İade
  dispose, // İmha
}

extension DrugOpExtension on DrugOp {
  String get label {
    switch (this) {
      case DrugOp.pull:
        return contextlessL10n().authorization_drugTable_pullColumn;
      case DrugOp.fill:
        return contextlessL10n().authorization_drugTable_fillColumn;
      case DrugOp.returnOp:
        return contextlessL10n().authorization_drugTable_returnColumn;
      case DrugOp.dispose:
        return contextlessL10n().authorization_drugTable_disposeColumn;
    }
  }
}
