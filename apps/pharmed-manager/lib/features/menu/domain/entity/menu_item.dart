import 'package:flutter/material.dart';

class MenuItem {
  final int? id;
  final int? parentId;
  final int? orderNo;
  final String? name;
  final String? label;
  final String? slug;
  final IconData? icon;
  final String? route;
  final bool? isManager;
  final String? description;
  final Widget Function(BuildContext context)? builder;
  final List<MenuItem> children;

  MenuItem({
    this.id,
    this.parentId,
    this.orderNo,
    this.name,
    this.label,
    this.slug,
    this.icon,
    this.route,
    this.isManager,
    this.builder,
    this.description,
    List<MenuItem>? children,
  }) : children = children ?? [];

  MenuItem copyWith({
    int? id,
    int? parentId,
    int? orderNo,
    String? name,
    String? label,
    String? slug,
    IconData? icon,
    String? route,
    String? description,
    Widget Function(BuildContext context)? builder,
    List<MenuItem>? children,
  }) {
    return MenuItem(
        id: id ?? this.id,
        parentId: parentId ?? this.parentId,
        label: label ?? this.label,
        name: name ?? this.name,
        orderNo: orderNo ?? this.orderNo,
        slug: slug ?? this.slug,
        icon: icon ?? this.icon,
        route: route ?? this.route,
        builder: builder ?? this.builder,
        children: children ?? this.children,
        description: description ?? this.description);
  }
}
