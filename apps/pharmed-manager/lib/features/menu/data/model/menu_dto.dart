class MenuDTO {
  final int? id;
  final int? parentId;
  final int? orderNo;
  final String? name;
  final String? appName;
  final String? slug;
  final String? unicode;
  final bool? isActive;
  final bool? isManager;
  final String? description;

  MenuDTO({
    this.id,
    this.parentId,
    this.orderNo,
    this.name,
    this.appName,
    this.slug,
    this.unicode,
    this.isActive,
    this.isManager,
    this.description,
  });

  factory MenuDTO.fromJson(Map<String, dynamic> json) {
    return MenuDTO(
      id: json['id'],
      parentId: json['parentId'],
      orderNo: json['orderNo'],
      name: json['name'],
      appName: json['appName'],
      slug: json['slug'],
      unicode: json['unicode'],
      isActive: json['isActive'],
      isManager: json['isManager'],
      description: json['description'],
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
