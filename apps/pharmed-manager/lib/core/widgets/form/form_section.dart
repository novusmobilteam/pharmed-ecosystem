import 'package:flutter/material.dart';
import 'form_field_metadata.dart';
// ignore_for_file: unintended_html_in_doc_comment

/// FORM BÖLÜM YÖNETİM SİSTEMİ
///
/// Bu dosya, form alanlarını mantıksal bölümlere ayırmak için tasarlanmıştır.
/// Büyük formlarda kullanıcı deneyimini iyileştirmek için formları bölümlere ayırır.
///
/// KULLANIM AMAÇLARI:
/// 1. Formları mantıksal gruplara bölmek
/// 2. Karmaşık formları düzenlemek
/// 3. Bölüm başlıkları ile kullanıcıya rehberlik etmek
/// 4. Responsive tasarımda bölüm bazlı kontrol sağlamak
///
/// AVANTAJLAR:
/// - Form organizasyonu sağlar
/// - Kullanıcı deneyimini iyileştirir
/// - Kod okunabilirliğini artırır
/// - Bölüm bazlı validasyon yapabilme imkanı

/// FORM BÖLÜM SINIFI
///
/// Form alanlarını gruplandırmak için kullanılır.
/// Her bölüm kendi içinde bağımsız bir form gibi davranabilir.
///
/// ÖZELLİKLER:
///
/// - title: Bölüm başlığı (opsiyonel)
/// - description: Bölüm açıklaması (opsiyonel)
/// - fields: Bu bölümdeki form alanları listesi
/// - columns: Bölümdeki sütun sayısı (mobil/masaüstü uyumlu)
/// - showBorder: Bölüm etrafında çerçeve gösterilsin mi?
/// - padding: Bölüm iç boşlukları
/// - crossAxisAlignment: Alanların dikey hizalaması
///
/// ÖRNEK KULLANIM:
/// ```dart
/// const personalInfoSection = FormSection(
///   title: 'Kişisel Bilgiler',
///   description: 'Temel kişisel bilgilerinizi girin',
///   columns: 2,
///   fields: [
///     FormFieldMetadata.text(key: 'name', label: 'Ad'),
///     FormFieldMetadata.text(key: 'surname', label: 'Soyad'),
///   ],
/// );
/// ```
class FormSection {
  /// Bölüm başlığı (örn: "Kişisel Bilgiler")
  final String? title;

  /// Bölüm açıklaması (detaylı bilgi)
  final String? description;

  /// Bu bölümdeki form alanları
  final List<FormFieldMetadata> fields;

  /// Bölümdeki sütun sayısı (responsive tasarım için)
  /// - 1: Tüm alanlar alt alta (mobil)
  /// - 2: İki sütunlu düzen (tablet)
  /// - 3+: Çok sütunlu düzen (masaüstü)
  final int columns;

  /// Bölüm etrafında çerçeve gösterilsin mi?
  /// - true: Kutucuk içinde göster
  /// - false: Normal göster
  final bool showBorder;

  /// Bölüm iç boşlukları
  final EdgeInsetsGeometry padding;

  /// Alanların dikey hizalaması
  final CrossAxisAlignment crossAxisAlignment;

  /// Kurucu metod
  const FormSection({
    this.title,
    this.description,
    required this.fields,
    this.columns = 2,
    this.showBorder = false,
    this.padding = const EdgeInsets.all(16.0),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Bölümdeki alan sayısını döndürür
  int get fieldCount => fields.length;

  /// Bölümdeki zorunlu alan sayısını döndürür
  int get requiredFieldCount {
    return fields.where((field) => field.isRequired).length;
  }

  /// Bölümün boş olup olmadığını kontrol eder
  bool get isEmpty => fields.isEmpty;

  /// Bölümdeki tüm alanların anahtarlarını döndürür
  List<String> get fieldKeys {
    return fields.map((field) => field.key).toList();
  }

  /// Debug bilgisi için string temsili
  @override
  String toString() {
    return 'FormSection(title: $title, fields: ${fields.length}, columns: $columns)';
  }
}

/// FORM BÖLÜM YÖNETİCİSİ
///
/// Form bölümleri ile ilgili yardımcı metodlar içerir.
///
/// METODLAR:
///
/// - validateSection: Bölümdeki tüm alanları validasyon yapar
/// - getSectionValues: Bölümdeki değerleri Map olarak döndürür
/// - getSectionErrors: Bölümdeki hataları Map olarak döndürür
class FormSectionHelper {
  /// Bölümdeki tüm alanları validasyondan geçirir
  ///
  /// PARAMETRELER:
  /// - section: Validasyon yapılacak bölüm
  /// - formValues: Form değerleri Map'i
  ///
  /// GERİ DÖNÜŞ:
  /// - Map<String, String?>: Anahtar-hata mesajı çiftleri
  ///   - null: Geçerli
  ///   - String: Hata mesajı
  static Map<String, String?> validateSection(
    FormSection section,
    Map<String, dynamic> formValues,
  ) {
    final errors = <String, String?>{};

    for (final field in section.fields) {
      final value = formValues[field.key];
      final error = field.validator?.call(value);

      // Zorunlu alan kontrolü
      if (field.isRequired && (value == null || value.toString().isEmpty)) {
        errors[field.key] = '${field.label} alanı zorunludur';
      } else if (error != null) {
        errors[field.key] = error;
      } else {
        errors[field.key] = null;
      }
    }

    return errors;
  }

  /// Bölümdeki tüm alanların değerlerini Map olarak döndürür
  ///
  /// PARAMETRELER:
  /// - section: Değerleri alınacak bölüm
  /// - formValues: Tüm form değerleri
  ///
  /// GERİ DÖNÜŞ:
  /// - Map<String, dynamic>: Anahtar-değer çiftleri
  static Map<String, dynamic> getSectionValues(
    FormSection section,
    Map<String, dynamic> formValues,
  ) {
    final sectionValues = <String, dynamic>{};

    for (final field in section.fields) {
      sectionValues[field.key] = formValues[field.key];
    }

    return sectionValues;
  }

  /// Bölümdeki tüm hataları Map olarak döndürür
  ///
  /// PARAMETRELER:
  /// - section: Hataları alınacak bölüm
  /// - formErrors: Tüm form hataları
  ///
  /// GERİ DÖNÜŞ:
  /// - Map<String, String?>: Anahtar-hata çiftleri
  static Map<String, String?> getSectionErrors(
    FormSection section,
    Map<String, String?> formErrors,
  ) {
    final sectionErrors = <String, String?>{};

    for (final field in section.fields) {
      sectionErrors[field.key] = formErrors[field.key];
    }

    return sectionErrors;
  }

  /// Bölümdeki tüm alanların geçerli olup olmadığını kontrol eder
  ///
  /// PARAMETRELER:
  /// - section: Kontrol edilecek bölüm
  /// - formErrors: Form hataları
  ///
  /// GERİ DÖNÜŞ:
  /// - bool: true = tüm alanlar geçerli
  static bool isSectionValid(
    FormSection section,
    Map<String, String?> formErrors,
  ) {
    for (final field in section.fields) {
      final error = formErrors[field.key];
      if (error != null && error.isNotEmpty) {
        return false;
      }
    }
    return true;
  }
}

/// FORM BÖLÜM GRUBU SINIFI
///
/// Birden fazla bölümü gruplamak için kullanılır.
/// Örneğin: "Kullanıcı Bilgileri" grubu içinde
/// - Kişisel Bilgiler bölümü
/// - İletişim Bilgileri bölümü
class FormSectionGroup {
  /// Grup adı
  final String name;

  /// Grup açıklaması
  final String? description;

  /// Grup içindeki bölümler
  final List<FormSection> sections;

  /// Grup sıra numarası (form içindeki sırası)
  final int order;

  /// Kurucu metod
  const FormSectionGroup({
    required this.name,
    this.description,
    required this.sections,
    this.order = 0,
  });

  /// Gruptaki toplam alan sayısı
  int get totalFieldCount {
    return sections.fold(0, (sum, section) => sum + section.fieldCount);
  }

  /// Gruptaki toplam bölüm sayısı
  int get sectionCount => sections.length;

  /// Grubun boş olup olmadığı
  bool get isEmpty => sections.isEmpty;

  /// Debug bilgisi
  @override
  String toString() {
    return 'FormSectionGroup(name: $name, sections: ${sections.length})';
  }
}

/// FORM BÖLÜM ÖRNEKLERİ (Demo amaçlı)
///
/// Bu örnekler, nasıl kullanılacağını göstermek içindir.
/// Gerçek projede domain/form/ altında olacaklar.
class ExampleFormSections {
  /// KİŞİSEL BİLGİLER BÖLÜMÜ ÖRNEĞİ
  ///
  /// 2 sütunlu, çerçeveli bir bölüm örneği
  static const personalInfoSection = FormSection(
    title: 'Kişisel Bilgiler',
    description: 'Temel kişisel bilgilerinizi giriniz',
    columns: 2,
    showBorder: true,
    fields: [
      // Burada FormFieldMetadata örnekleri olacak
      // Örnek: FormFieldMetadata.text(key: 'name', label: 'Ad')
    ],
  );

  /// İLETİŞİM BİLGİLERİ BÖLÜMÜ ÖRNEĞİ
  ///
  /// 3 sütunlu, çerçevesiz bir bölüm örneği
  static const contactInfoSection = FormSection(
    title: 'İletişim Bilgileri',
    columns: 3,
    showBorder: false,
    padding: EdgeInsets.symmetric(vertical: 12.0),
    fields: [
      // Form alanları buraya gelecek
    ],
  );

  /// ADRES BİLGİLERİ BÖLÜMÜ ÖRNEĞİ
  ///
  /// Tek sütunlu, geniş alanlar için örnek
  static const addressInfoSection = FormSection(
    title: 'Adres Bilgileri',
    columns: 1,
    showBorder: true,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    fields: [
      // Form alanları buraya gelecek
    ],
  );
}

/// TEST VE DEBUG İÇİN YARDIMCI METODLAR
extension FormSectionDebugExtensions on FormSection {
  /// Bölüm bilgilerini detaylı olarak yazdırır
  void printDebugInfo() {
    debugPrint('=== BÖLÜM BİLGİLERİ ===');
    debugPrint('Başlık: $title');
    debugPrint('Açıklama: $description');
    debugPrint('Alan Sayısı: $fieldCount');
    debugPrint('Zorunlu Alan Sayısı: $requiredFieldCount');
    debugPrint('Sütun Sayısı: $columns');
    debugPrint('Çerçeve: ${showBorder ? "Var" : "Yok"}');
    debugPrint('--- Alan Listesi ---');

    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      debugPrint('${i + 1}. ${field.label} (${field.key}) - ${field.fieldType}');
    }

    debugPrint('=====================\n');
  }

  /// Bölümün JSON temsilini döndürür (debug için)
  Map<String, dynamic> toDebugMap() {
    return {
      'title': title,
      'description': description,
      'fieldCount': fieldCount,
      'requiredFieldCount': requiredFieldCount,
      'columns': columns,
      'showBorder': showBorder,
      'fields': fields.map((f) => f.key).toList(),
    };
  }
}
