import 'package:flutter/material.dart';

IconData? iconDataFromUnicode(String? unicode) {
  if (unicode == null || unicode.isEmpty) return null;

  return IconData(
    int.parse(unicode),
    fontFamily: 'PhosphorRegular',
    fontPackage: 'phosphor_flutter',
  );
}
