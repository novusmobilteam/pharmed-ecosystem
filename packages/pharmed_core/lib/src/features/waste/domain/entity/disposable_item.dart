// [SWREQ-CORE-DISPOSAL-001] [IEC 62304 §5.5]
//
// Fire/imha adayı bir reçete kalemi. CabinTargetedPrescriptionItem AİLESİNE
// DAHİL DEĞİL — çekmece/göz hedefi yok (imha donanımla ilgili bir işlem
// değil, ilaç ayrı bir kutuya atılıyor). WitnessContext taşır (imha
// isWastageWitnessedPurchase flag'ine bağlı şahitlik gerektirebilir).
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class DisposableItem {
  const DisposableItem({
    required this.id,
    required this.medicine,
    required this.dosePiece,
    this.hospitalization,
    this.lastMovement,
    this.time,
    this.witnessContext = const WitnessContext(),
  });

  final int id;
  final Medicine? medicine;
  final num dosePiece;
  final Hospitalization? hospitalization;
  final PrescriptionItemMovement? lastMovement;
  final DateTime? time;
  final WitnessContext witnessContext;

  PrescriptionMovementType? get status => lastMovement?.type;

  bool needsWitness({Station? currentStation}) {
    final drug = medicine is Drug ? medicine as Drug : null;
    if (drug == null) return false;
    return witnessContext.needsWitness(
      requiresWitness: drug.isWastageWitnessedPurchase,
      currentStation: currentStation,
    );
  }

  DisposableItem copyWith({num? dosePiece, WitnessContext? witnessContext}) {
    return DisposableItem(
      id: id,
      medicine: medicine,
      dosePiece: dosePiece ?? this.dosePiece,
      hospitalization: hospitalization,
      lastMovement: lastMovement,
      time: time,
      witnessContext: witnessContext ?? this.witnessContext,
    );
  }
}
