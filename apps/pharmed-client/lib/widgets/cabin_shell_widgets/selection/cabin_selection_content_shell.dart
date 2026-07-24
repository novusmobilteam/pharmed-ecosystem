// Master kabin seçim ekranlarının (dolum, sayım...) sağ slotunun içerik
// kabuğu. MasterRefillSelectionPanel'in dış Container'ından çıkarıldı —
// hangi içeriğin (ilaç grid'i, çekmece rehberi vb.) gösterileceğini bilmiyor,
// tamamen slot tabanlı.

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../widgets.dart';

class CabinSelectionContentShell extends StatelessWidget {
  const CabinSelectionContentShell({
    super.key,
    this.header,
    this.content,
    this.footer,
    required this.searchQuery,
    required this.onSearchQueryChanged,
    this.searchHint,
    this.isLoading = false,
    this.isEmpty = false,
    this.loadingMessage,
    this.emptyMessage,
  }) : assert(isLoading || isEmpty || content != null, 'content is required unless isLoading or isEmpty is true');

  /// Genelde [CabinSelectionHeader].
  final Widget? header;

  /// Asıl seçim alanı: ilaç grid'i, boş durum, ya da (sayımda) sol
  /// CabinLocationGuide + sağ grid kombinasyonu — tamamen çağıranın kararı.
  final Widget? content;

  /// true iken [content] yerine ortalanmış bir loading indicator gösterilir.
  /// Ekran ilk açılışta (notifier henüz state üretmediyse) kullanılır.
  final bool isLoading;

  /// true iken [content] yerine boş-durum mesajı gösterilir. [isLoading]'den
  /// sonra kontrol edilir; ikisi birden true ise loading kazanır.
  final bool isEmpty;

  /// Genelde [CabinSelectionStartBar]. null ise hiç render edilmez — ör.
  /// hiçbir seçim yokken "başlat" barının kapladığı boşluk bile kalmasın.
  final Widget? footer;

  final String searchQuery;
  final ValueChanged<String> onSearchQueryChanged;
  final String? searchHint;

  final String? loadingMessage;
  final String? emptyMessage;

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            if (loadingMessage != null) Text(loadingMessage!, style: MedTextStyles.bodyMd(color: MedColors.text3)),
          ],
        ),
      );
    }

    if (isEmpty) {
      return Center(
        child: EmptyStateWidget(variant: EmptyStateVariant.noData, title: emptyMessage),
      );
    }

    return content!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: MedSpacing.panelInsetPadding,
      decoration: MedDecoration.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ?header,
          if (header != null) const SizedBox(height: 16.0),
          CabinOperationSearchField(onChanged: onSearchQueryChanged, hintText: searchHint),
          const SizedBox(height: 16.0),
          Expanded(child: _buildBody(context)),
          if (footer != null) ...[const SizedBox(height: 16.0), footer!],
        ],
      ),
    );
  }
}
