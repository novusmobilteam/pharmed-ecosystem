import 'package:pharmed_manager/core/core.dart';

/// PrescriptionItem → CabinOperationItem dönüşümü.
/// Fire/imha akışında kullanılır.
///
/// [witnesses] ve [stations]: İlaç isWitnessedDisposal ise servisden
/// gelen liste buraya geçirilir. Değilse boş liste bırakılır.
extension CabinOperationItemMapper on PrescriptionItem {
  CabinOperationItem toCabinOperationItem({
    List<User> witnesses = const [],
    List<Station> stations = const [],
    User? witness,
  }) {
    return CabinOperationItem(
      id: id ?? 0,
      operationType: CabinOperationType.disposal,
      medicine: medicine,
      dosePiece: dosePiece?.toDouble(),
      // Fire/imha'da doğrudan bir CabinAssignment bağlantısı gelmediği için null.
      // Stok gösterimi gerekirse ileride doldurulabilir.
      assignment: null,
      // Fire/imha reçete bağlamını taşır (firstDoseEmergency vb. göstermek için)
      // ancak prescriptionDose ve withdrawType alıma özgüdür.
      prescriptionItem: PrescriptionItem(
        id: id,
        dosePiece: dosePiece,
        time: time,
        firstDoseEmergency: firstDoseEmergency,
        askDoctor: askDoctor,
        inCaseOfNecessity: inCaseOfNecessity,
        medicine: medicine,
      ),
      prescriptionDose: null,
      withdrawType: null,
      witnesses: witnesses,
      stations: stations,
      witness: witness,
      status: status,
    );
  }
}
