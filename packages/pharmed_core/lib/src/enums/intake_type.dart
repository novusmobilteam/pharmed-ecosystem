/// Alım Tipi
/// Orderlı, Ordersız ve Serbest İlaç
enum IntakeType { ordered, orderless, free, urgent }

extension IntakeTypeExtension on IntakeType {
  /// Reçete-dışı akışlar: ordersız, serbest, acil. Bu üçünde de ortada bir
  /// reçete kalemi (PrescriptionItem) olmadığı için RxOrdersContent kartında
  /// stepper/şahit alanları seçilmeden de gösterilir.
  bool get isOrderless => this != IntakeType.ordered;
}
