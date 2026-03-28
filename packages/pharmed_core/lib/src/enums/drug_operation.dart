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
        return 'İlaç Çeker';
      case DrugOp.fill:
        return 'Dolum';
      case DrugOp.returnOp:
        return 'İade';
      case DrugOp.dispose:
        return 'İmha';
    }
  }
}
