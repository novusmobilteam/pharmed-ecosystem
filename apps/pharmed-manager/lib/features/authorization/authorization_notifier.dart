import 'package:flutter/material.dart';

import '../../core/core.dart';

enum AuthorizationPanelType { user, role }

class AuthorizationNotifier extends ChangeNotifier with SidePanelMixin<void, AuthorizationPanelType> {
  int _activeIndex = 0;
  int get activeIndex => _activeIndex;
  set activeIndex(int value) {
    if (_activeIndex == value) return;
    _activeIndex = value;
    closePanel();
    notifyListeners();
  }

  User? _selectedUser;
  User? get selectedUser => _selectedUser;

  Role? _selectedRole;
  Role? get selectedRole => _selectedRole;

  void openUserPanel({User? user}) {
    _selectedUser = user;
    _selectedRole = null;
    openPanel(type: AuthorizationPanelType.user);
  }

  void openRolePanel({Role? role}) {
    _selectedRole = role;
    _selectedUser = null;
    openPanel(type: AuthorizationPanelType.role);
  }

  @override
  void closePanel() {
    _selectedUser = null;
    _selectedRole = null;
    super.closePanel();
  }
}
