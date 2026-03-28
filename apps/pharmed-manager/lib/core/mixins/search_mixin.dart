import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';

mixin SearchMixin<T extends TableData> on ChangeNotifier {
  // Değişkenler
  String _searchQuery = '';
  List<T> _allItems = [];

  // Getter'lar
  String get searchQuery => _searchQuery;
  bool get hasSearch => _searchQuery.isNotEmpty;
  bool get hasNoSearchResults => hasSearch && filteredItems.isEmpty;

  // Filtrelenmiş liste - tüm content alanlarında arama yapar
  List<T> get filteredItems {
    if (_searchQuery.isEmpty) {
      return _allItems;
    }

    final query = _searchQuery.trim().toLowerCase();

    return _allItems.where((item) {
      // Tüm content alanlarında arama yap
      for (final field in item.content) {
        final fieldString = field?.toString().toLowerCase() ?? '';
        if (fieldString.contains(query)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  // Setter'lar
  set allItems(List<T> items) {
    _allItems = items;
  }

  List<T> get allItems => _allItems;

  bool get isEmpty => allItems.isEmpty;

  // Metodlar
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Arama durumuna göre liste döndürür
  List<T> get currentItems => hasSearch ? filteredItems : allItems;
}
