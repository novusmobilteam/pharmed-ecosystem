// [SWREQ-CORE-CABIN-ITEM-001] [IEC 62304 §5.5]
//
// Bir reçete satırının, kabindeki fiziksel bir çekmece/göze bağlı hâlini
// temsil eder — alım ("buradan al") ve iade ("buraya geri koy") ekranlarında
// ortak kullanılır. Fire/imha'da böyle bir hedef YOK (bkz. imha akışı, ayrı
// bir entity ailesi), bu yüzden bu sınıf her zaman bir MedicineAssignment
// (çekmece/göz adresi + stok) taşımak ZORUNDADIR.
//
// Kullanım: alım ekranında kullanıcı bu item'ı seçip miktar girer, seçim
// CabinOperationTarget'a (requestedQuantity ile) map edilerek çekmece
// açılışı tetiklenir. İade ekranında aynı akış tersine (stok azalmak yerine
// artar).
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class CabinTargetedPrescriptionItem {
  const CabinTargetedPrescriptionItem({
    required this.id,
    required this.prescriptionId,
    required this.dosePiece,
    required this.cabinAssignment,
    this.hospitalization,
    this.medicine,
    this.firstDoseEmergency = false,
    this.askDoctor = false,
    this.inCaseOfNecessity = false,
    this.time,
    this.stock,
    this.lastMovement,
  });

  final int id;
  final int prescriptionId;
  final num dosePiece;
  final DateTime? time;
  final bool firstDoseEmergency;
  final bool askDoctor;
  final bool inCaseOfNecessity;
  final Medicine? medicine;
  final Hospitalization? hospitalization;

  /// Bu satırın hedeflediği çekmece/göz — alımda "buradan al", iadede
  /// "buraya koy". Bu ailenin (fire/imha'dan ayrılan) tanımlayıcı alanı.
  final MedicineAssignment cabinAssignment;

  final CabinStock? stock;
  final PrescriptionItemMovement? lastMovement;

  /// medicine null gelirse (ör. malzeme silinmiş) kullanıcıya gösterilecek
  /// güvenli varsayılan — medicine ile her zaman senkron, ayrı bir alan
  /// olarak SAKLANMAZ.
  String get medicineName => medicine?.name ?? contextlessL10n().cabinCore_unknownMedicineFallback;
  String get medicineBarcode => medicine?.barcode ?? '';

  factory CabinTargetedPrescriptionItem.empty(MedicineAssignment? assignment) {
    return CabinTargetedPrescriptionItem(
      id: 0,
      prescriptionId: 0,
      dosePiece: 0,
      cabinAssignment: assignment ?? MedicineAssignment.empty(cabinId: 0, cabinDrawerId: 0),
    );
  }
}
