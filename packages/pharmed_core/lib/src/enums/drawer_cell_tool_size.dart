import 'package:pharmed_ui/pharmed_ui.dart';

/// Serum rafı üzerindeki avadanlığın (tepsi) boyutu.
/// API'de `toolSize` alanına karşılık gelir.
enum DrawerCellToolSize {
  small(1),
  medium(2),
  large(3);

  const DrawerCellToolSize(this.apiValue);
  final int apiValue;

  String get label => switch (this) {
    DrawerCellToolSize.small => contextlessL10n().cabinDesign_serum_traySizeSmallLabel,
    DrawerCellToolSize.medium => contextlessL10n().cabinDesign_serum_traySizeMediumLabel,
    DrawerCellToolSize.large => contextlessL10n().cabinDesign_serum_traySizeLargeLabel,
  };
}
