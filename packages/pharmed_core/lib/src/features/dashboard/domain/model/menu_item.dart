import 'package:flutter/material.dart';

class MenuItem {
  final int? id;
  final int? parentId;
  final int? orderNo;
  final String? name;
  final String? label;
  final String? slug;
  final String? unicode;
  final String? route;
  final bool? isManager;
  final String? description;
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
    String? unicode,
    String? route,
    String? description,
    List<MenuItem>? children,
  }) {
    return MenuItem(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      label: label ?? this.label,
      name: name ?? this.name,
      orderNo: orderNo ?? this.orderNo,
      slug: slug ?? this.slug,
      unicode: unicode ?? this.unicode,
      route: route ?? this.route,
      children: children ?? this.children,
      description: description ?? this.description,
    );
  }
}
