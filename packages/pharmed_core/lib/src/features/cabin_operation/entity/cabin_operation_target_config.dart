// [SWREQ-CORE-CABINOP-009] [IEC 62304 §5.5]
//
// CabinOperationTarget'ın bir işlemden diğerine değişen TEK davranışını
// taşır: primary (fiziksel sayım) miktarının yanında ikinci bir miktar
// alanı var mı. Dolumda bu ikincil alan "konulacak miktar"dır, boşaltmada
// "çıkarılacak miktar"dır — ikisinde de var. Sayımda kullanıcı yalnızca
// fiziksel sayımı girer, ikincil alan yoktur.
//
// Sınıf: Class B

class CabinOperationTargetConfig {
  const CabinOperationTargetConfig({required this.hasSecondaryField});

  /// true → primary'nin yanında ikinci bir miktar alanı var, "girdi" bu
  /// alana bakar (dolum: filling, boşaltma: unload). false → yok, "girdi"
  /// doğrudan primary'e (countQuantity) bakar (sayım).
  final bool hasSecondaryField;
}

/// Dolum: kullanıcı hem sayım hem konulacak miktarı girer.
const refillTargetConfig = CabinOperationTargetConfig(hasSecondaryField: true);

/// Sayım: kullanıcı yalnızca fiziksel sayımı girer.
const censusTargetConfig = CabinOperationTargetConfig(hasSecondaryField: false);

/// Boşaltma: kullanıcı hem sayım hem çıkarılacak miktarı girer.
const unloadTargetConfig = CabinOperationTargetConfig(hasSecondaryField: true);

/// İmha: sayım gibi tek alan (hasSecondaryField: false) ama stoktan hiç
/// ön-doldurma yapılmaz — kullanıcı her gözde miktarı bilinçli girmeli.
const destructionTargetConfig = CabinOperationTargetConfig(hasSecondaryField: false);
