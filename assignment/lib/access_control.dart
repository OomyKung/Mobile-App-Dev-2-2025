import 'package:flutter/foundation.dart';

import 'asset_service.dart';

class AccessControl extends ChangeNotifier {
  AccessControl._();

  static final AccessControl instance = AccessControl._();

  String _activeUserId = 'local-admin';
  String _activeUserName = 'Local Admin';
  String _activeRole = AssetService.roleAdmin;

  String get activeUserId => _activeUserId;
  String get activeUserName => _activeUserName;
  String get activeRole => _activeRole;

  void switchRole(String role) {
    final normalized = AssetService().normalizeRole(role);
    if (normalized == _activeRole) return;
    _activeRole = normalized;
    notifyListeners();
  }

  void switchActor({
    required String userId,
    required String userName,
    required String role,
  }) {
    _activeUserId = userId.trim().isEmpty ? _activeUserId : userId.trim();
    _activeUserName = userName.trim().isEmpty
        ? _activeUserName
        : userName.trim();
    _activeRole = AssetService().normalizeRole(role);
    notifyListeners();
  }

  bool can(String permission) {
    return AssetService.canRole(_activeRole, permission);
  }
}
