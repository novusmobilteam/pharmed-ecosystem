import '../../../drug_class/domain/entity/drug_class.dart';
import '../../../drug_type/domain/entity/drug_type.dart';
import '../../../material_type/domain/entity/material_type.dart';
import '../../../station/domain/entity/station.dart';
import '../../../unit/domain/entity/unit.dart';

import '../../../../core/core.dart';
import '../../../dosage_form/domain/entity/dosage_form.dart';
import '../../../firm/domain/entity/firm.dart';
import '../../data/model/medicine_dto.dart';

part 'drug.dart';
part 'medical_consumable.dart';

/// Tek üst entity: ilaç da olabilir sarf da.
/// UI ve iş kuralları katmanında union gibi kullanman için 'when' sağlıyor.
sealed class Medicine extends Selectable implements TableData {
  Medicine({required super.title, super.subtitle, super.id});

  bool get isDrug {
    final self = this;
    return self is Drug;
  }

  String? get name {
    final self = this;
    if (self is Drug) return self.name;
    if (self is MedicalConsumable) return self.name;
    return null;
  }

  String? get barcode {
    final self = this;
    if (self is Drug) return self.barcode;
    if (self is MedicalConsumable) return self.barcode;
    return null;
  }

  int? get type {
    final self = this;
    if (self is Drug) return 1;
    if (self is MedicalConsumable) return 2;
    return null;
  }

  String? get typeLabel {
    final self = this;
    if (self is Drug) return self.drugType?.name;
    if (self is MedicalConsumable) return self.materialType?.name;
    return null;
  }

  PurchaseType? get purchaseType {
    final self = this;
    if (self is Drug) return self.purchaseType;
    if (self is MedicalConsumable) return self.purchaseType;
    return null;
  }

  CountType? get countType {
    final self = this;
    if (self is Drug) return self.countType;
    if (self is MedicalConsumable) return self.countType;
    return null;
  }

  ReturnType? get returnType {
    final self = this;
    if (self is Drug) return self.returnType;
    if (self is MedicalConsumable) return self.returnType;
    return null;
  }

  PrescriptionType? get prescriptionType {
    final self = this;
    if (self is Drug) return self.prescriptionType;
    if (self is MedicalConsumable) return null;
    return null;
  }

  @override
  List<String?> get titles => const [
    'Barkod',
    'ATC Kodu',
    'Adı',
    'Malzeme Türü',
    'Reçete Tipi',
    'Sayım Tipi',
    'Alım Şekli',
    'İade Şekli',
    'Aktif',
  ];

  @override
  List<String?> get content => when(
    drug: (d) => [
      d.barcode,
      d.atcCode?.toCustomString(),
      d.name,
      'İlaç',
      d.prescriptionType.label,
      d.countType.label,
      d.purchaseType.label,
      d.returnType?.label,
      d.status.label,
    ],
    consumable: (m) => [
      m.barcode,
      '',
      m.name,
      'Tıbbi Sarf',
      '',
      m.countType?.label,
      m.purchaseType?.label,
      m.returnType?.label,
      m.status.label,
    ],
  );

  static Medicine? fromIdAndName({int? id, String? name, required bool isMaterial, String? barcode}) {
    // Eğer entity_barrel.dart'tan kaçınmak istiyorsak:
    if (isMaterial) {
      return Drug(id: id, name: name, barcode: barcode);
    } else {
      return MedicalConsumable(id: id, name: name, status: Status.active, barcode: barcode);
    }
  }

  T when<T>({required T Function(Drug drug) drug, required T Function(MedicalConsumable consumable) consumable}) {
    final self = this;

    if (self.runtimeType == Drug) {
      return drug(self as Drug);
    }
    if (self.runtimeType == MedicalConsumable) {
      return consumable(self as MedicalConsumable);
    }

    if (self is Drug) return drug(self);
    if (self is MedicalConsumable) return consumable(self);

    throw StateError('Unknown Medicine subtype: $runtimeType');
  }

  MedicineDTO toDTO() {
    return when(drug: (drug) => drug.toDto(), consumable: (consumable) => consumable.toDto());
  }
}

/// Medicine için doz yapılandırması.
///
/// Uygulama genelinde doz hesaplama, gösterim ve adım mantığı
/// bu extension üzerinden yapılır. Notifier ve widget'larda
/// doğrudan Drug field'larına erişmek yerine bu extension kullanılır.
///
/// Üç senaryo:
/// 1. MedicalConsumable → her zaman Adet bazında
/// 2. Drug, isMeasureUnit = false → Adet bazında
/// 3. Drug, isMeasureUnit = true → ölçü birimi (ml vb.) bazında
///    İlaç Atama, İlaç Dolum, Dolum Listesi ve İlaç Sayım'da kullanıcı Adet girer, sistem adet×dose kaydeder
extension MedicineDoseConfig on Medicine {
  // ---------------------------------------------------------------------------
  // Birim adı
  // ---------------------------------------------------------------------------

  /// Kullanıcıya gösterilen birim adı.
  /// Örn: "Adet", "ml", "mg"
  String get operationUnit {
    final self = this;
    if (self is! Drug) return 'Adet';
    if (!self.isMeasureUnit) return 'Adet';
    return self.unitMeasure?.name ?? 'Adet';
  }

  /// Dolum ekranında kullanılan birim adı.
  /// isMeasureUnit true olsa bile dolumda kullanıcı Adet girer.
  String get fillingUnit => 'Adet';

  // ---------------------------------------------------------------------------
  // Adım miktarı
  // ---------------------------------------------------------------------------

  /// Stepper'da her adımda artacak/azalacak miktar.
  /// isMeasureUnit = true ise doseMeasureUnit (örn: 5ml), değilse 1.
  double get operationStep {
    final self = this;
    if (self is! Drug) return 1.0;
    if (!self.isMeasureUnit) return 1.0;
    return self.doseMeasureUnit?.toDouble() ?? 1.0;
  }

  // ---------------------------------------------------------------------------
  // Dolum çarpanı
  // ---------------------------------------------------------------------------

  /// Dolumda kullanıcının girdiği adet değerini backend'e göndermek için
  /// çarpılacak değer.
  /// isMeasureUnit = true ise dose (örn: 100ml), değilse 1.
  ///
  /// Örnek: kullanıcı 3 adet girdiyse → 3 × 100ml = 300ml backend'e gönderilir.
  double get fillingMultiplier {
    final self = this;
    if (self is! Drug) return 1.0;
    if (!self.isMeasureUnit) return 1.0;
    return self.dose?.toDouble() ?? 1.0;
  }

  // ---------------------------------------------------------------------------
  // Miktar doğrulama
  // ---------------------------------------------------------------------------

  /// Girilen miktarın ölçü birimi adımına uygun olup olmadığını kontrol eder.
  /// isMeasureUnit = false veya MedicalConsumable ise her zaman true döner.
  ///
  /// Örnek: operationStep = 5ml ise 10, 15, 20 geçerli; 7 geçersiz.
  bool isValidAmount(double amount) {
    if (operationStep <= 1.0) return true;
    // Kayan nokta hassasiyeti için epsilon kontrolü
    final remainder = amount % operationStep;
    return remainder < 0.001 || (operationStep - remainder) < 0.001;
  }

  /// Girilen miktarı en yakın geçerli adıma yuvarlar.
  double snapToStep(double amount) {
    if (operationStep <= 1.0) return amount;
    return (amount / operationStep).round() * operationStep;
  }

  // ---------------------------------------------------------------------------
  // Gösterim
  // ---------------------------------------------------------------------------

  /// Miktarı birim ile birlikte gösterir.
  /// Örn: "50 ml", "3 Adet"
  String formatAmount(double amount) {
    final formatted = amount == amount.toInt() ? amount.toInt().toString() : amount.toString();
    return '$formatted $operationUnit';
  }

  /// Dolum adet girişini backend değerine çevirir.
  /// Örn: 3 adet × 100ml = 300ml
  double toFillingBackendValue(num pieceAmount) {
    return pieceAmount * fillingMultiplier;
  }

  /// Backend'den gelen dolum değerini adet gösterimine çevirir.
  /// Örn: 300ml ÷ 100ml = 3 adet
  double fromFillingBackendValue(num backendValue) {
    if (fillingMultiplier <= 0) return backendValue.toDouble();
    return backendValue / fillingMultiplier;
  }

  /// Boşaltma/imha ekranında sayım alanı birimi.
  ///
  /// isMeasureUnit=true → "adet × 100ml" (mevcut stok adet + doz formatında)
  /// Diğer durumlarda → "Adet"
  ///
  /// ⚠ Skill §5: unload/disposal'da mevcut stok "X adet × Y ml" olarak gösterilir.
  String get unloadCountUnit {
    final self = this;
    if (self is Drug && self.isMeasureUnit && fillingMultiplier > 1) {
      final dose = self.dose;
      final doseFormatted = dose == dose?.toInt() ? '${dose?.toInt()}' : '$dose';
      final volumeUnit = self.doseUnit?.name ?? 'ml';
      return 'adet × $doseFormatted$volumeUnit';
    }
    return 'Adet';
  }
}
