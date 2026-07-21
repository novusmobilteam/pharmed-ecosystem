import 'dart:ui';

class MenuItem {
  final int? id;
  final int? parentId;
  final int? orderNo;

  /// Varsayılan (TR) isim — geriye dönük uyumluluk için korunur.
  final String? name;

  /// Locale'e göre formatlanmış isim (sidebar label vb.).
  /// appName varsa onu, yoksa localizedName'i baz alır.
  final String? label;

  final String? slug;
  final String? unicode;
  final String? route;
  final bool? isManager;
  final bool? isMobile;

  /// Varsayılan (TR) açıklama — geriye dönük uyumluluk için korunur.
  final String? description;

  /// Çok dilli isimler: {'tr': '...', 'en': '...', 'ar': '...'}
  final Map<String, String> names;

  /// Çok dilli açıklamalar: {'tr': '...', 'en': '...', 'ar': '...'}
  final Map<String, String> descriptions;

  final List<MenuItem> children;

  MenuItem({
    this.id,
    this.parentId,
    this.orderNo,
    this.name,
    this.label,
    this.slug,
    this.unicode,
    this.route,
    this.isManager,
    this.isMobile,
    this.description,
    Map<String, String>? names,
    Map<String, String>? descriptions,
    List<MenuItem>? children,
  }) : names = names ?? {},
       descriptions = descriptions ?? {},
       children = children ?? [];

  /// Verilen locale için menü adını döner.
  /// Sıra: istenen dil → TR → map'teki ilk değer → boş string
  String localizedName(Locale locale) => _localized(names, locale);

  /// Verilen locale için açıklamayı döner.
  String localizedDescription(Locale locale) => _localized(descriptions, locale);

  String _localized(Map<String, String> map, Locale locale) {
    if (map.isEmpty) return '';
    return map[locale.languageCode] ?? map['tr'] ?? map.values.first;
  }

  MenuItem copyWith({
    int? id,
    int? parentId,
    int? orderNo,
    String? name,
    String? label,
    String? slug,
    String? unicode,
    String? route,
    String? description,
    Map<String, String>? names,
    Map<String, String>? descriptions,
    List<MenuItem>? children,
  }) {
    return MenuItem(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      orderNo: orderNo ?? this.orderNo,
      name: name ?? this.name,
      label: label ?? this.label,
      slug: slug ?? this.slug,
      unicode: unicode ?? this.unicode,
      route: route ?? this.route,
      isManager: isManager ?? this.isManager,
      isMobile: isMobile ?? this.isMobile,
      description: description ?? this.description,
      names: names ?? this.names,
      descriptions: descriptions ?? this.descriptions,
      children: children ?? this.children,
    );
  }
}
