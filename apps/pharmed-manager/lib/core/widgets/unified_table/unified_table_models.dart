import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core.dart';

enum TableSelectionMode {
  /// Seçim yok — satırlara tıklanamaz
  none,

  /// Tekli seçim — aynı anda sadece 1 satır seçili, radio göstergesi
  single,

  /// Çoklu seçim — checkbox kolonu, "Tümünü Seç" başlık checkbox'ı
  multi,
}

// ─── COLUMN DEF ──────────────────────────────────────────────────────────────
//
// columnDefs verilirse item.titles / numericColumnIndices / columnFlexes yerine
// bu liste kullanılır. Kolon başlığını, genişliğini, tipi ve hangi content
// index'ini göstereceğini tanımlar.
//
// Kullanım örneği (tab index'e göre farklı kolonlar):
//
//   columnDefs: [
//     TableColumnDef(title: index == 2 ? 'T.C Kimlik No' : 'Kurum Sicil No',
//                    contentIndex: 0),
//     TableColumnDef(title: 'Adı', contentIndex: 1),
//     TableColumnDef(title: 'Soyadı', contentIndex: 2),
//     if (index == 0)
//       TableColumnDef(title: 'Meslek Tipi', contentIndex: 3),
//     if (index != 0)
//       TableColumnDef(title: 'Son Geçerlilik Tarihi', contentIndex: 4),
//     TableColumnDef(title: 'Durumu', contentIndex: 5, flex: 0.8),
//   ],

class TableColumnDef {
  const TableColumnDef({
    required this.title,

    /// item.content[contentIndex] değerini bu kolona bağlar.
    /// null → cellBuilder ile tamamen özel render (value parametresi null gelir)
    this.contentIndex,

    /// Flex genişliği (varsayılan 1.0)
    this.flex = 1.0,

    /// true → sıralanabilir (rawContent üzerinden); false → filtrelenebilir
    this.numeric = false,
  });

  final String title;
  final int? contentIndex;
  final double flex;
  final bool numeric;
}

/// Belirli bir hücre için özel widget döndürür.
/// [colIndex]  → kolonun listedeki sırası (0-based)
/// [value]     → item.content[contentIndex] (contentIndex null ise null)
/// null döndürülürse varsayılan text render kullanılır.
typedef CellBuilder<T extends TableData> = Widget? Function(
  T item,
  int colIndex,
  dynamic value,
);

class TableSideCategory {
  final String id;
  final String label;
  final int? count;
  const TableSideCategory({
    required this.id,
    required this.label,
    this.count,
  });
}

// ─── ACTION ITEM ─────────────────────────────────────────────────────────────

class TableActionItem<T extends TableData> {
  final IconData icon;
  final String tooltip;
  final Color? color;
  final void Function(T item) onPressed;

  /// null → her satırda göster
  final bool Function(T item)? isVisible;

  const TableActionItem({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.isVisible,
  });

  factory TableActionItem.edit({required void Function(T item) onPressed}) {
    return TableActionItem(
      icon: PhosphorIcons.pen(),
      tooltip: 'Düzenle',
      onPressed: onPressed,
    );
  }

  factory TableActionItem.delete({required void Function(T item) onPressed}) {
    return TableActionItem(
      icon: PhosphorIcons.trashSimple(),
      tooltip: 'Sil',
      color: Colors.red,
      onPressed: onPressed,
    );
  }
}
