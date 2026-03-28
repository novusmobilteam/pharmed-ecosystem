import 'package:flutter/material.dart';

/// Bu sistem, form alanlarını dinamik olarak yönetmek için tasarlanmıştır.
/// Her form alanı için tüm bilgileri (tip, validasyon, layout vs.) bir yerde tutar.
///
/// KULLANIM AMAÇLARI:
/// 1. Form alanlarını merkezi olarak yönetmek
/// 2. Kod tekrarını önlemek
/// 3. Form yapılarını dinamik hale getirmek
/// 4. Responsive layout'u kolaylaştırmak
///
/// AVANTAJLAR:
/// - Yeni form eklemek çok hızlı
/// - Bakımı kolay
/// - Tutarlı form yapısı
/// - Masaüstü ve mobil uyumlu

/// ALAN TİPLERİ
/// Formdaki her input'un tipini belirler.
///
/// Örnek Kullanımlar:
/// - `FieldType.text`: Normal yazı input'u
/// - `FieldType.dropdown`: Seçim listesi
/// - `FieldType.dialog`: Pop-up seçim penceresi
/// - `FieldType.date`: Tarih seçici
enum FieldType {
  /// Metin girişi (TextFormField)
  text,

  /// Sayısal giriş (numara)
  number,

  /// Açılır liste seçimi
  dropdown,

  /// Dialog penceresinden seçim
  dialog,

  /// Tarih seçici
  date,

  /// Saat seçici
  time,

  /// Checkbox (evet/hayır)
  checkbox,

  /// Çoklu seçim (birden fazla seçenek)
  multiSelect,

  /// Radio button (tekli seçim)
  radio,

  /// Özel widget (custom yapı)
  custom,
}

/// ALAN LAYOUT AYARLARI
/// Form alanlarının ekranda nasıl yerleşeceğini belirler.
///
/// 🔸 `flex`: Bölünebilir alan sisteminde kaç birim yer kaplayacağı
///   - Örnek: 3 kolonlu sistemde flex:2 -> 2/3 alan kaplar
///
/// 🔸 `breakAfter`: Bu alandan sonra yeni satıra geçilsin mi?
///   - true: Sonraki alan alt satıra geçer
///   - false: Yan yana devam eder
///
/// 🔸 `minWidth`/`maxWidth`: Minimum ve maksimum genişlik sınırları
class FieldLayout {
  final int flex;
  final bool breakAfter;
  final double? minWidth;
  final double? maxWidth;

  const FieldLayout({
    this.flex = 1,
    this.breakAfter = false,
    this.minWidth,
    this.maxWidth,
  });

  @override
  String toString() {
    return 'FieldLayout(flex: $flex, breakAfter: $breakAfter)';
  }
}

/// FORM ALANI META VERİ SINIFI
///
/// Her form alanı için gerekli tüm bilgileri içerir.
/// Bu sınıf sayesinde form alanlarını JSON gibi tanımlayabiliriz.
///
/// ÖZELLİKLER:
///
/// `key`: Alanın benzersiz anahtarı (JSON key gibi)
///  - Örnek: 'email', 'username', 'phone'
///
/// `label`: Input'un üstünde gözüken başlık
///  - Örnek: 'E-posta Adresi', 'Kullanıcı Adı'
///
/// `hintText`: Input içindeki gri açıklama metni
///  - Örnek: 'email@example.com'
///
/// `initialValue`: Form ilk açıldığında gözükecek değer
///  - Düzenleme modunda kullanılır
///
/// `isRequired`: Zorunlu alan mı?
///  - true ise boş bırakılamaz
///
/// `validator`: Özel validasyon fonksiyonu
///  - Hata mesajı döndürmeli veya null
///
/// `fieldType`: Alanın tipi (yukarıdaki FieldType enum'ı)
///
/// `additionalData`: Ekstra veri (dropdown options, repository vs.)
///
/// `layout`: Ekranda nasıl yerleşeceği
///
/// `enabled`: Input aktif/pasif durumu
///
/// `prefixIcon`/`suffixIcon`: Input'un sol/sağ ikonları
abstract class FormFieldMetadata<T> {
  /// Alanın benzersiz anahtarı (veritabanı kolonu gibi)
  final String key;

  /// Kullanıcıya gösterilecek başlık
  final String label;

  /// Input içindeki açıklama metni
  final String? hintText;

  /// Form ilk açıldığındaki değer (düzenleme için)
  final T? initialValue;

  /// Zorunlu alan mı? (boş bırakılamaz)
  final bool isRequired;

  /// Özel validasyon fonksiyonu
  /// Geri dönüş: null = geçerli, String = hata mesajı
  final String? Function(T? value)? validator;

  /// Alan tipi (text, dropdown, date vb.)
  final FieldType fieldType;

  /// Ekstra veri (seçenekler, repository vs.)
  /// Dropdown: List<Option>
  /// Dialog: Repository
  /// Date: DateTime başlangıç değeri
  final dynamic additionalData;

  /// Ekrandaki yerleşim bilgisi
  final FieldLayout layout;

  /// Input aktif mi? (false ise disabled)
  final bool enabled;

  /// Input'un solundaki ikon
  final Widget? prefixIcon;

  /// Input'un sağındaki ikon
  final Widget? suffixIcon;

  const FormFieldMetadata({
    required this.key,
    required this.label,
    this.hintText,
    this.initialValue,
    this.isRequired = false,
    this.validator,
    required this.fieldType,
    this.additionalData,
    this.layout = const FieldLayout(),
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  String toString() {
    return 'FormFieldMetadata(key: $key, label: $label, type: $fieldType)';
  }
}

/// HIZLI BAŞLANGIÇ İÇİN FACTORY METODLARI
///
/// Sık kullanılan alan tipleri için hazır metodlar.
/// Bu metodlar kod yazmayı %70 azaltır!
extension FormFieldFactory on FormFieldMetadata {
  /// Metin alanı oluştur (hızlı yöntem)
  static FormFieldMetadata<String> text({
    required String key,
    required String label,
    String? hintText,
    String? initialValue,
    bool isRequired = false,
    String? Function(String? value)? validator,
    FieldLayout layout = const FieldLayout(),
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return _FormFieldMetadataImpl<String>(
      key: key,
      label: label,
      hintText: hintText,
      initialValue: initialValue,
      isRequired: isRequired,
      validator: validator,
      fieldType: FieldType.text,
      layout: layout,
      enabled: enabled,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  /// Sayısal alan oluştur
  static FormFieldMetadata<int> number({
    required String key,
    required String label,
    String? hintText,
    int? initialValue,
    bool isRequired = false,
    String? Function(int? value)? validator,
    FieldLayout layout = const FieldLayout(),
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return _FormFieldMetadataImpl<int>(
      key: key,
      label: label,
      hintText: hintText,
      initialValue: initialValue,
      isRequired: isRequired,
      validator: validator,
      fieldType: FieldType.number,
      layout: layout,
      enabled: enabled,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  /// Dropdown alanı oluştur
  static FormFieldMetadata<T> dropdown<T>({
    required String key,
    required String label,
    required List<T> options,
    T? initialValue,
    bool isRequired = false,
    String? Function(T? value)? validator,
    FieldLayout layout = const FieldLayout(),
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return _FormFieldMetadataImpl<T>(
      key: key,
      label: label,
      initialValue: initialValue,
      isRequired: isRequired,
      validator: validator,
      fieldType: FieldType.dropdown,
      additionalData: options,
      layout: layout,
      enabled: enabled,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  /// Tarih alanı oluştur
  static FormFieldMetadata<DateTime> date({
    required String key,
    required String label,
    String? hintText,
    DateTime? initialValue,
    bool isRequired = false,
    String? Function(DateTime? value)? validator,
    FieldLayout layout = const FieldLayout(),
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return _FormFieldMetadataImpl<DateTime>(
      key: key,
      label: label,
      hintText: hintText,
      initialValue: initialValue,
      isRequired: isRequired,
      validator: validator,
      fieldType: FieldType.date,
      layout: layout,
      enabled: enabled,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}

/// PRIVATE IMPLEMENTATION
/// FormFieldMetadata abstract sınıfının gerçek implementasyonu.
/// Dışarıdan direkt erişilemez, factory metodlarla kullanılır.
class _FormFieldMetadataImpl<T> extends FormFieldMetadata<T> {
  const _FormFieldMetadataImpl({
    required super.key,
    required super.label,
    super.hintText,
    super.initialValue,
    super.isRequired = false,
    super.validator,
    required super.fieldType,
    super.additionalData,
    super.layout = const FieldLayout(),
    super.enabled = true,
    super.prefixIcon,
    super.suffixIcon,
  });
}

/// TEST İÇİN ÖRNEK KULLANIM
/// 
/// void main() {
///   // 1. Basit metin alanı
///   final emailField = FormFieldMetadata.text(
///     key: 'email',
///     label: 'E-posta',
///     hintText: 'ornek@mail.com',
///     isRequired: true,
///     validator: (value) {
///       if (!value!.contains('@')) return 'Geçerli bir e-posta girin';
///       return null;
///     },
///   );
/// 
///   // 2. Dropdown alanı
///   final genderField = FormFieldMetadata.dropdown(
///     key: 'gender',
///     label: 'Cinsiyet',
///     options: ['Erkek', 'Kadın', 'Diğer'],
///     isRequired: true,
///   );
/// 
///   // 3. Responsive layout'lu alan
///   final nameField = FormFieldMetadata.text(
///     key: 'name',
///     label: 'Ad Soyad',
///     layout: FieldLayout(flex: 2, breakAfter: true),
///   );
/// 
///   print(emailField); // Debug çıktısı
/// }