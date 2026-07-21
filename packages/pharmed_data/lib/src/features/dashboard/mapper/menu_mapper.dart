import 'package:pharmed_core/pharmed_core.dart';

abstract class MenuRouteResolver {
  String? resolve(String? slug);
}

class MenuTreeMapper {
  final MenuRouteResolver? routeResolver;

  const MenuTreeMapper({this.routeResolver});

  MenuItem toEntity(MenuDTO dto) {
    final slug = dto.slug;
    final routeName = routeResolver?.resolve(slug) ?? slug;

    // label: appName öncelikli, yoksa TR isim — mevcut davranış korundu
    final String formattedLabel = (dto.appName ?? dto.name ?? '').replaceAll('/n', '\n').trim();

    return MenuItem(
      id: dto.id,
      parentId: dto.parentId,
      orderNo: dto.orderNo,
      name: dto.name, // TR — geriye dönük uyumluluk
      label: formattedLabel,
      slug: slug,
      unicode: dto.unicode,
      route: routeName,
      isManager: dto.isManager ?? false,
      isMobile: dto.isMobile,
      description: dto.description, // TR — geriye dönük uyumluluk
      names: {
        if (dto.name != null) 'tr': dto.name!,
        if (dto.nameEn != null) 'en': dto.nameEn!,
        if (dto.nameAr != null) 'ar': dto.nameAr!,
        if (dto.nameFr != null) 'fr': dto.nameFr!,
      },
      descriptions: {
        if (dto.description != null) 'tr': dto.description!,
        if (dto.descriptionEn != null) 'en': dto.descriptionEn!,
        if (dto.descriptionAr != null) 'ar': dto.descriptionAr!,
        if (dto.descriptionFr != null) 'fr': dto.descriptionFr!,
      },
      children: [],
    );
  }

  List<MenuItem> toTreeList(List<MenuDTO> dtos) {
    final activeDtos = dtos.where((d) => d.isActive != false).toList();
    final Map<int, MenuItem> itemMap = {};
    final List<MenuItem> rootItems = [];

    for (final dto in activeDtos) {
      if (dto.id != null) itemMap[dto.id!] = toEntity(dto);
    }

    for (final dto in activeDtos) {
      final current = itemMap[dto.id];
      if (current == null) continue;

      if (dto.parentId == null || dto.parentId == 0) {
        rootItems.add(current);
      } else {
        final parent = itemMap[dto.parentId];
        if (parent != null) {
          parent.children.add(current);
        } else {
          rootItems.add(current);
        }
      }
    }

    _sortMenu(rootItems);
    return rootItems;
  }

  void _sortMenu(List<MenuItem> items) {
    items.sort((a, b) => (a.orderNo ?? 0).compareTo(b.orderNo ?? 0));
    for (final item in items) {
      _sortMenu(item.children);
    }
  }
}
