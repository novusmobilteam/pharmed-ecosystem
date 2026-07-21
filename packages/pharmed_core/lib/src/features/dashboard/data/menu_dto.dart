class MenuDTO {
  final int? id;
  final int? parentId;
  final int? orderNo;
  final String? name; // TR (varsayılan)
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;
  final String? appName;
  final String? slug;
  final String? unicode;
  final String? icon;
  final String? controller;
  final bool? isActive;
  final bool? isManager;
  final bool? isMobile;
  final bool? isNoAuthorization;
  final String? description; // TR
  final String? descriptionEn;
  final String? descriptionAr;
  final String? descriptionFr;

  const MenuDTO({
    this.id,
    this.parentId,
    this.orderNo,
    this.name,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.appName,
    this.slug,
    this.unicode,
    this.icon,
    this.controller,
    this.isActive,
    this.isManager,
    this.isMobile,
    this.isNoAuthorization,
    this.description,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionFr,
  });

  factory MenuDTO.fromJson(Map<String, dynamic> json) {
    return MenuDTO(
      id: json['id'],
      parentId: json['parentId'],
      orderNo: json['orderNo'],
      name: json['name'],
      nameEn: json['nameEn'],
      nameAr: json['nameAr'],
      nameFr: json['nameFr'],
      appName: json['appName'],
      slug: json['slug'],
      unicode: json['unicode'],
      icon: json['icon'],
      controller: json['controller'],
      isActive: json['isActive'],
      isManager: json['isManager'],
      isMobile: json['isMobileMenu'],
      isNoAuthorization: json['isNoAuthorization'],
      description: json['description'],
      descriptionEn: json['descriptionEn'],
      descriptionAr: json['descriptionAr'],
      descriptionFr: json['descriptionFr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'orderNo': orderNo,
      'name': name,
      'slug': slug,
      'unicode': unicode,
      'isActive': isActive,
      'isManager': isManager,
    };
  }
}
