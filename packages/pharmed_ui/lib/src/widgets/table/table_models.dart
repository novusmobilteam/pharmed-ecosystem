import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
// bu liste kullanılır. Kolon kendi başlığını, genişliğini, tipini, nasıl
// render edileceğini (cellBuilder) ve filtre/export/sıralama değerlerini
// (displayValue / sortValue) TEK YERDE tanımlar.
//
// Değer kaynağı önceliği:
//   • displayValue verilmişse → filtre, export, sıralama, fallback text ONU kullanır
//   • yoksa → item.content[contentIndex] (klasik yol)
//
// Görsel:
//   • cellBuilder verilmişse → hücre onunla çizilir (chip, ikon vb.)
//     (cellBuilder içindeki stilsiz Text'ler tablo hücre stilini otomatik alır)
//   • yoksa → displayValue / content düz Text olarak basılır
//
// Kullanım örneği (görsel + filtre/export aynı kaynaktan):
//
//   TableColumnDef<PrescriptionItem>(
//     title: 'İşlem',
//     displayValue: (i) => i.lastMovement?.type.label ?? '-',   // filtre + export
//     cellBuilder: (i) => i.lastMovement != null                // görsel
//         ? MedRxMovementChip(status: i.lastMovement!.type)
//         : Text(i.lastMovement?.type.label ?? '-'),
//   ),

class TableColumnDef<T> {
  const TableColumnDef({
    required this.title,

    /// item.content[contentIndex] değerini bu kolona bağlar.
    /// displayValue verilmişse yok sayılır.
    this.contentIndex,

    /// Flex genişliği (varsayılan 1.0)
    this.flex = 1.0,

    /// true → sıralanabilir sayısal kolon
    this.numeric = false,

    /// Görsel hücre (opsiyonel). Verilmezse displayValue/content düz Text basılır.
    /// Döndürdüğü widget tablo hücre stiliyle otomatik sarılır.
    this.cellBuilder,

    /// Filtre + export + sıralama + fallback text için görünür string.
    /// cellBuilder kullanılsa bile filtre/export bunu okur — bu yüzden
    /// cellBuilder'lı kolonlarda da doldurulması önerilir.
    this.displayValue,

    /// Sıralama için karşılaştırılabilir ham değer.
    /// Verilmezse displayValue string'i üzerinden sıralanır.
    this.sortValue,
  });

  final String title;
  final int? contentIndex;
  final double flex;
  final bool numeric;
  final Widget? Function(T item)? cellBuilder;
  final String? Function(T item)? displayValue;
  final Comparable? Function(T item)? sortValue;
}

/// Belirli bir hücre için özel widget döndürür.
/// [colIndex]  → kolonun listedeki sırası (0-based)
/// [value]     → item.content[contentIndex] (contentIndex null ise null)
/// null döndürülürse varsayılan text render kullanılır.
typedef CellBuilder<T extends Object> = Widget? Function(T item, int colIndex, dynamic value);

class TableSideCategory {
  final String id;
  final String label;
  final int? count;
  const TableSideCategory({required this.id, required this.label, this.count});
}

// ─── ACTION ITEM ─────────────────────────────────────────────────────────────

class TableActionItem<T extends Object> {
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

  factory TableActionItem.edit({required BuildContext context, required void Function(T item) onPressed}) {
    return TableActionItem(icon: PhosphorIcons.pen(), tooltip: context.l10n.common_editTooltip, onPressed: onPressed);
  }

  factory TableActionItem.delete({required BuildContext context, required void Function(T item) onPressed}) {
    return TableActionItem(
      icon: PhosphorIcons.trashSimple(),
      tooltip: context.l10n.common_deleteTooltip,
      color: Colors.red,
      onPressed: onPressed,
    );
  }
}
