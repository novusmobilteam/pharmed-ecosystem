// [SWREQ-XX] side_panel_mixin.dart
// packages/pharmed_ui/lib/src/mixins/side_panel_mixin.dart
// (veya apps/pharmed-manager/lib/core/mixins/)

import 'package:flutter/foundation.dart';

/// SidePanelWrapper ile çalışan Notifier'lara panel açma/kapama
/// state yönetimini sağlayan mixin.
///
/// Kullanım:
/// ```dart
/// class FirmFormNotifier extends ChangeNotifier with SidePanelMixin {
///   ...
/// }
/// ```
mixin SidePanelMixin<T, P> on ChangeNotifier {
  bool _isPanelOpen = false;
  T? _selectedItem;
  P? _panelType;

  bool get isPanelOpen => _isPanelOpen;
  T? get selectedItem => _selectedItem;
  P? get panelType => _panelType;
  bool get isEditing => _selectedItem != null;

  void openPanel({T? item, P? type}) {
    _selectedItem = item;
    _panelType = type;
    _isPanelOpen = true;
    notifyListeners();
  }

  void closePanel() {
    if (!_isPanelOpen) return;
    _isPanelOpen = false;
    _selectedItem = null;
    _panelType = null;
    notifyListeners();
  }

  void togglePanel({T? item, P? type}) {
    _isPanelOpen ? closePanel() : openPanel(item: item, type: type);
  }
}
