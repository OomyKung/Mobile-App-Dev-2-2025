import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'asset_item.dart';
import 'asset_ops_models.dart';

class AssetSummary {
  final int total;
  final int normal;
  final int repair;
  final int disposed;
  final int checkedOut;
  final int overdueCheckout;
  final Map<String, int> byLocation;

  const AssetSummary({
    required this.total,
    required this.normal,
    required this.repair,
    required this.disposed,
    required this.checkedOut,
    required this.overdueCheckout,
    required this.byLocation,
  });

  int get active => total - disposed;
  double get healthyRatio => total == 0 ? 0 : normal / total;

  factory AssetSummary.fromItems(List<AssetItem> items) {
    var normal = 0;
    var repair = 0;
    var disposed = 0;
    var checkedOut = 0;
    var overdueCheckout = 0;
    final now = DateTime.now();
    final locations = <String, int>{};

    for (final item in items) {
      switch (item.status) {
        case AssetService.statusNormal:
          normal++;
          break;
        case AssetService.statusRepair:
          repair++;
          break;
        case AssetService.statusDisposed:
          disposed++;
          break;
      }

      if (item.isCheckedOut) {
        checkedOut++;
        if (item.checkoutDueAt != null && item.checkoutDueAt!.isBefore(now)) {
          overdueCheckout++;
        }
      }

      final location = item.location.trim();
      final key = location.isEmpty ? 'Unspecified' : location;
      locations[key] = (locations[key] ?? 0) + 1;
    }

    return AssetSummary(
      total: items.length,
      normal: normal,
      repair: repair,
      disposed: disposed,
      checkedOut: checkedOut,
      overdueCheckout: overdueCheckout,
      byLocation: Map.unmodifiable(locations),
    );
  }
}

class AssetService {
  AssetService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const _opTimeout = Duration(seconds: 20);

  static const statusAll = 'ALL';
  static const statusNormal = 'NORMAL';
  static const statusRepair = 'REPAIR';
  static const statusDisposed = 'DISPOSED';
  static const validStatuses = {statusNormal, statusRepair, statusDisposed};

  static const roleAdmin = 'ADMIN';
  static const roleStaff = 'STAFF';
  static const roleViewer = 'VIEWER';
  static const validRoles = {roleAdmin, roleStaff, roleViewer};

  static const maintenanceOpen = 'OPEN';
  static const maintenanceInProgress = 'IN_PROGRESS';
  static const maintenanceDone = 'DONE';
  static const maintenanceCancelled = 'CANCELLED';
  static const validMaintenanceStatuses = {
    maintenanceOpen,
    maintenanceInProgress,
    maintenanceDone,
    maintenanceCancelled,
  };

  static const checkoutCheckedOut = 'CHECKED_OUT';
  static const checkoutReturned = 'RETURNED';
  static const checkoutOverdue = 'OVERDUE';
  static const validCheckoutStatuses = {
    checkoutCheckedOut,
    checkoutReturned,
    checkoutOverdue,
  };

  static const stocktakeOpen = 'OPEN';
  static const stocktakeClosed = 'CLOSED';

  static const notificationInfo = 'INFO';
  static const notificationWarn = 'WARN';
  static const notificationCritical = 'CRITICAL';
  static const validNotificationLevels = {
    notificationInfo,
    notificationWarn,
    notificationCritical,
  };

  static const notificationNew = 'NEW';
  static const notificationRead = 'READ';
  static const notificationResolved = 'RESOLVED';
  static const validNotificationStatuses = {
    notificationNew,
    notificationRead,
    notificationResolved,
  };

  static const permissionViewAssets = 'VIEW_ASSETS';
  static const permissionCreateAsset = 'CREATE_ASSET';
  static const permissionEditAsset = 'EDIT_ASSET';
  static const permissionDeleteAsset = 'DELETE_ASSET';
  static const permissionManageUsers = 'MANAGE_USERS';
  static const permissionManageMaintenance = 'MANAGE_MAINTENANCE';
  static const permissionManageCheckout = 'MANAGE_CHECKOUT';
  static const permissionManageStocktake = 'MANAGE_STOCKTAKE';
  static const permissionManageNotifications = 'MANAGE_NOTIFICATIONS';
  static const permissionManageAttachments = 'MANAGE_ATTACHMENTS';
  static const permissionImportExport = 'IMPORT_EXPORT';
  static const permissionViewAudit = 'VIEW_AUDIT';

  static const Map<String, Set<String>> _rolePermissions = {
    roleAdmin: {
      permissionViewAssets,
      permissionCreateAsset,
      permissionEditAsset,
      permissionDeleteAsset,
      permissionManageUsers,
      permissionManageMaintenance,
      permissionManageCheckout,
      permissionManageStocktake,
      permissionManageNotifications,
      permissionManageAttachments,
      permissionImportExport,
      permissionViewAudit,
    },
    roleStaff: {
      permissionViewAssets,
      permissionCreateAsset,
      permissionEditAsset,
      permissionManageMaintenance,
      permissionManageCheckout,
      permissionManageStocktake,
      permissionManageNotifications,
      permissionManageAttachments,
      permissionImportExport,
      permissionViewAudit,
    },
    roleViewer: {permissionViewAssets, permissionViewAudit},
  };

  static bool _offlineConfigured = false;

  late final CollectionReference<Map<String, dynamic>> _col = _db.collection(
    'assets',
  );
  late final CollectionReference<Map<String, dynamic>> _usersCol = _db
      .collection('users');
  late final CollectionReference<Map<String, dynamic>> _auditCol = _db
      .collection('asset_audit_logs');
  late final CollectionReference<Map<String, dynamic>> _maintenanceCol = _db
      .collection('maintenance_tickets');
  late final CollectionReference<Map<String, dynamic>> _checkoutCol = _db
      .collection('asset_checkouts');
  late final CollectionReference<Map<String, dynamic>> _stocktakeCol = _db
      .collection('stocktake_sessions');
  late final CollectionReference<Map<String, dynamic>> _notificationCol = _db
      .collection('asset_notifications');
  late final CollectionReference<Map<String, dynamic>> _attachmentCol = _db
      .collection('asset_attachments');

  static bool canRole(String role, String permission) {
    final normalizedRole = role.trim().toUpperCase();
    final normalizedPermission = permission.trim().toUpperCase();
    final allowed = _rolePermissions[normalizedRole];
    if (allowed == null) return false;
    return allowed.contains(normalizedPermission);
  }

  static Future<void> configureOfflineSupport() async {
    if (_offlineConfigured) return;
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _offlineConfigured = true;
    } catch (_) {
      // Ignore when settings were already configured elsewhere.
    }
  }

  int _clampLimit(int limit, {int min = 1, int max = 500}) {
    if (limit < min) return min;
    if (limit > max) return max;
    return limit;
  }

  String newAssetId() => _col.doc().id;
  String newMaintenanceId() => _maintenanceCol.doc().id;
  String newCheckoutId() => _checkoutCol.doc().id;
  String newStocktakeId() => _stocktakeCol.doc().id;

  String normalizeAssetCode(String code) => code.trim().toUpperCase();

  String normalizeRole(String role) {
    final normalized = role.trim().toUpperCase();
    if (validRoles.contains(normalized)) return normalized;
    return roleViewer;
  }

  String normalizeStatus(String status) {
    final normalized = status.trim().toUpperCase();
    if (validStatuses.contains(normalized)) return normalized;
    return statusNormal;
  }

  String normalizeStatusFilter(String status) {
    final normalized = status.trim().toUpperCase();
    if (normalized == statusAll) return statusAll;
    if (validStatuses.contains(normalized)) return normalized;
    return statusAll;
  }

  String normalizeMaintenanceStatus(String status) {
    final normalized = status.trim().toUpperCase();
    if (validMaintenanceStatuses.contains(normalized)) return normalized;
    return maintenanceOpen;
  }

  String normalizeCheckoutStatus(String status) {
    final normalized = status.trim().toUpperCase();
    if (validCheckoutStatuses.contains(normalized)) return normalized;
    return checkoutCheckedOut;
  }

  String normalizeNotificationLevel(String level) {
    final normalized = level.trim().toUpperCase();
    if (validNotificationLevels.contains(normalized)) return normalized;
    return notificationInfo;
  }

  String normalizeNotificationStatus(String status) {
    final normalized = status.trim().toUpperCase();
    if (validNotificationStatuses.contains(normalized)) return normalized;
    return notificationNew;
  }

  String extractAssetCode(String rawInput) {
    final raw = rawInput.trim();
    if (raw.isEmpty) return '';

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      final queryCode =
          uri.queryParameters['assetCode'] ?? uri.queryParameters['code'];
      if (queryCode != null && queryCode.trim().isNotEmpty) {
        return normalizeAssetCode(queryCode);
      }
      if (uri.pathSegments.isNotEmpty) {
        final lastSegment = uri.pathSegments.last.trim();
        if (lastSegment.isNotEmpty && !lastSegment.contains('.')) {
          return normalizeAssetCode(lastSegment);
        }
      }
    }

    final candidate = raw.replaceFirst(RegExp(r'^[A-Za-z]+:'), '').trim();
    final firstToken = candidate.split(RegExp(r'\s+')).first;
    return normalizeAssetCode(firstToken);
  }

  bool matchesKeyword(AssetItem item, String keyword) {
    final needle = keyword.trim().toLowerCase();
    if (needle.isEmpty) return true;

    final haystack = [
      item.assetCode,
      item.type,
      item.brand,
      item.detail,
      item.location,
      item.status,
      item.statusNote ?? '',
      item.currentBorrower ?? '',
    ].join(' ').toLowerCase();
    return haystack.contains(needle);
  }

  List<AssetItem> filterItems(
    List<AssetItem> items, {
    String keyword = '',
    String status = statusAll,
  }) {
    final filter = AssetSearchFilter(keyword: keyword, status: status);
    return filterItemsAdvanced(items, filter);
  }

  List<AssetItem> filterItemsAdvanced(
    List<AssetItem> items,
    AssetSearchFilter filter,
  ) {
    final normalizedStatus = normalizeStatusFilter(filter.status);
    final keyword = filter.keyword.trim().toLowerCase();
    final type = filter.type.trim().toLowerCase();
    final brand = filter.brand.trim().toLowerCase();
    final location = filter.location.trim().toLowerCase();
    final from = filter.updatedFrom;
    final to = filter.updatedTo;

    return items.where((item) {
      if (normalizedStatus != statusAll && item.status != normalizedStatus) {
        return false;
      }
      if (keyword.isNotEmpty && !matchesKeyword(item, keyword)) return false;
      if (type.isNotEmpty && !item.type.toLowerCase().contains(type)) {
        return false;
      }
      if (brand.isNotEmpty && !item.brand.toLowerCase().contains(brand)) {
        return false;
      }
      if (location.isNotEmpty &&
          !item.location.toLowerCase().contains(location)) {
        return false;
      }
      if (filter.onlyNeverScanned && item.lastScannedAt != null) {
        return false;
      }
      if (filter.onlyCheckedOut && !item.isCheckedOut) {
        return false;
      }
      if (from != null && item.updatedAt.isBefore(from)) {
        return false;
      }
      if (to != null && item.updatedAt.isAfter(to)) {
        return false;
      }
      return true;
    }).toList();
  }

  Stream<List<AssetItem>> watchAll() {
    return _col.orderBy('updatedAt', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) => AssetItem.fromMap(d.id, d.data())).toList();
    });
  }

  Stream<AppSyncState> watchSyncState() {
    return _col.snapshots(includeMetadataChanges: true).map((snap) {
      final hasPendingWrites = snap.docs.any(
        (d) => d.metadata.hasPendingWrites,
      );
      return AppSyncState(
        isFromCache: snap.metadata.isFromCache,
        hasPendingWrites: hasPendingWrites,
        observedAt: DateTime.now(),
      );
    });
  }

  Stream<List<AssetItem>> watchByStatus(String status) {
    final normalized = normalizeStatusFilter(status);
    if (normalized == statusAll) return watchAll();
    return _col
        .where('status', isEqualTo: normalized)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((d) => AssetItem.fromMap(d.id, d.data()))
              .toList();
        });
  }

  Stream<List<AssetItem>> watchFiltered({
    String keyword = '',
    String status = statusAll,
  }) {
    final filter = AssetSearchFilter(keyword: keyword, status: status);
    return watchAll().map((items) => filterItemsAdvanced(items, filter));
  }

  Stream<List<AssetItem>> watchFilteredAdvanced(AssetSearchFilter filter) {
    return watchAll().map((items) => filterItemsAdvanced(items, filter));
  }

  Stream<AssetSummary> watchSummary() {
    return watchAll().map(AssetSummary.fromItems);
  }

  Stream<AssetItem?> watchById(String id) {
    return _col.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AssetItem.fromMap(doc.id, doc.data()!);
    });
  }

  Future<AssetItem?> getById(String id) async {
    final doc = await _col.doc(id).get().timeout(_opTimeout);
    if (!doc.exists) return null;
    return AssetItem.fromMap(doc.id, doc.data()!);
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _queryAssetCodeDocs(
    String code, {
    int limit = 5,
  }) async {
    final safeLimit = _clampLimit(limit, max: 50);
    final normalizedCode = normalizeAssetCode(code);
    if (normalizedCode.isEmpty) return [];

    final normalizedKey = normalizedCode.toLowerCase();
    final keyedQuery = await _col
        .where('assetCodeLower', isEqualTo: normalizedKey)
        .limit(safeLimit)
        .get()
        .timeout(_opTimeout);
    if (keyedQuery.docs.isNotEmpty) return keyedQuery.docs;

    final fallbackCandidates = <String>{
      normalizedCode,
      code.trim(),
      code.trim().toLowerCase(),
      code.trim().toUpperCase(),
    }..removeWhere((value) => value.isEmpty);

    for (final candidate in fallbackCandidates) {
      final result = await _col
          .where('assetCode', isEqualTo: candidate)
          .limit(safeLimit)
          .get()
          .timeout(_opTimeout);
      if (result.docs.isNotEmpty) return result.docs;
    }

    return [];
  }

  Future<AssetItem?> getByAssetCode(String code) async {
    final docs = await _queryAssetCodeDocs(code, limit: 1);
    if (docs.isEmpty) return null;
    final doc = docs.first;
    return AssetItem.fromMap(doc.id, doc.data());
  }

  Future<bool> assetCodeExists(String code, {String? exceptId}) async {
    final docs = await _queryAssetCodeDocs(code, limit: 5);
    if (docs.isEmpty) return false;
    if (exceptId == null) return true;
    return docs.any((doc) => doc.id != exceptId);
  }

  Map<String, dynamic> _prepareWriteData(
    Map<String, dynamic> input, {
    required bool includeCreatedAt,
  }) {
    final data = Map<String, dynamic>.from(input);
    final now = DateTime.now();

    if (includeCreatedAt && !data.containsKey('createdAt')) {
      data['createdAt'] = now;
    }
    data['updatedAt'] = now;

    if (data.containsKey('assetCode') && data['assetCode'] is! FieldValue) {
      final normalizedCode = normalizeAssetCode(
        (data['assetCode'] ?? '').toString(),
      );
      data['assetCode'] = normalizedCode;
      if (normalizedCode.isEmpty) {
        data.remove('assetCodeLower');
      } else {
        data['assetCodeLower'] = normalizedCode.toLowerCase();
      }
    }

    if (data.containsKey('status') && data['status'] is! FieldValue) {
      data['status'] = normalizeStatus((data['status'] ?? '').toString());
    }

    return data;
  }

  Future<void> _safeLogAudit({
    required String action,
    required String entityType,
    required String entityId,
    required String message,
    required String actorName,
    required String actorRole,
    Map<String, dynamic>? payload,
    String? resolutionKey,
  }) async {
    try {
      await logAudit(
        action: action,
        entityType: entityType,
        entityId: entityId,
        message: message,
        actorName: actorName,
        actorRole: actorRole,
        payload: payload,
        resolutionKey: resolutionKey,
      );
    } catch (_) {
      // Never block main workflow on audit errors.
    }
  }

  Future<String> createAsset(
    Map<String, dynamic> data, {
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final payload = _prepareWriteData(data, includeCreatedAt: true);
    final doc = await _col.add(payload).timeout(_opTimeout);
    await _safeLogAudit(
      action: 'ASSET_CREATE',
      entityType: 'asset',
      entityId: doc.id,
      message: 'Created asset ${payload['assetCode'] ?? ''}'.trim(),
      actorName: actorName,
      actorRole: actorRole,
      payload: payload,
    );
    return doc.id;
  }

  Future<void> createAssetWithId(
    String id,
    Map<String, dynamic> data, {
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final payload = _prepareWriteData(data, includeCreatedAt: true);
    await _col.doc(id).set(payload).timeout(_opTimeout);
    await _safeLogAudit(
      action: 'ASSET_CREATE',
      entityType: 'asset',
      entityId: id,
      message: 'Created asset ${payload['assetCode'] ?? ''}'.trim(),
      actorName: actorName,
      actorRole: actorRole,
      payload: payload,
    );
  }

  Future<void> updateAsset(
    String id,
    Map<String, dynamic> data, {
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final payload = _prepareWriteData(data, includeCreatedAt: false);
    await _col.doc(id).update(payload).timeout(_opTimeout);
    await _safeLogAudit(
      action: 'ASSET_UPDATE',
      entityType: 'asset',
      entityId: id,
      message: 'Updated asset $id',
      actorName: actorName,
      actorRole: actorRole,
      payload: payload,
    );
  }

  Future<void> updateAssetStatus(
    String id,
    String status, {
    String? note,
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final payload = <String, dynamic>{'status': normalizeStatus(status)};
    if (note != null) {
      final normalizedNote = note.trim();
      payload['statusNote'] = normalizedNote.isEmpty ? null : normalizedNote;
    }
    await updateAsset(id, payload, actorName: actorName, actorRole: actorRole);
  }

  Future<void> transferAssetLocation(
    String id,
    String newLocation, {
    String? note,
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final payload = <String, dynamic>{'location': newLocation.trim()};
    if (note != null) {
      final normalizedNote = note.trim();
      payload['statusNote'] = normalizedNote.isEmpty ? null : normalizedNote;
    }
    await updateAsset(id, payload, actorName: actorName, actorRole: actorRole);
  }

  Future<void> markAssetScanned(
    String id, {
    DateTime? scannedAt,
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    await updateAsset(
      id,
      {'lastScannedAt': scannedAt ?? DateTime.now()},
      actorName: actorName,
      actorRole: actorRole,
    );
  }

  Future<List<AssetItem>> searchAssets({
    String keyword = '',
    String status = statusAll,
    int limit = 200,
  }) async {
    final filter = AssetSearchFilter(keyword: keyword, status: status);
    return searchAssetsAdvanced(filter, limit: limit);
  }

  Future<List<AssetItem>> searchAssetsAdvanced(
    AssetSearchFilter filter, {
    int limit = 300,
  }) async {
    final safeLimit = _clampLimit(limit, max: 2000);
    final querySnapshot = await _col
        .orderBy('updatedAt', descending: true)
        .limit(safeLimit)
        .get()
        .timeout(_opTimeout);
    final items = querySnapshot.docs
        .map((doc) => AssetItem.fromMap(doc.id, doc.data()))
        .toList();
    return filterItemsAdvanced(items, filter);
  }

  Future<List<AssetItem>> getRecentlyUpdated({int limit = 20}) async {
    final safeLimit = _clampLimit(limit, max: 200);
    final querySnapshot = await _col
        .orderBy('updatedAt', descending: true)
        .limit(safeLimit)
        .get()
        .timeout(_opTimeout);
    return querySnapshot.docs
        .map((doc) => AssetItem.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> deleteAsset(
    String id, {
    String actorName = 'System',
    String actorRole = roleAdmin,
  }) async {
    final existing = await getById(id);
    await _col.doc(id).delete().timeout(_opTimeout);
    await _safeLogAudit(
      action: 'ASSET_DELETE',
      entityType: 'asset',
      entityId: id,
      message: 'Deleted asset ${existing?.assetCode ?? id}',
      actorName: actorName,
      actorRole: actorRole,
      payload: {'assetCode': existing?.assetCode},
    );
  }

  Stream<List<AssetUserProfile>> watchUsers({bool activeOnly = false}) {
    Query<Map<String, dynamic>> query = _usersCol.orderBy('displayName');
    if (activeOnly) {
      query = query.where('active', isEqualTo: true);
    }
    return query.snapshots().map((snap) {
      return snap.docs
          .map((doc) => AssetUserProfile.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<AssetUserProfile?> getUserProfile(String userId) async {
    final doc = await _usersCol.doc(userId).get().timeout(_opTimeout);
    if (!doc.exists) return null;
    return AssetUserProfile.fromMap(doc.id, doc.data()!);
  }

  Future<void> upsertUserProfile({
    required String userId,
    required String displayName,
    String email = '',
    String role = roleStaff,
    bool active = true,
    String actorName = 'System',
    String actorRole = roleAdmin,
  }) async {
    final now = DateTime.now();
    final normalizedRole = normalizeRole(role);
    final payload = <String, dynamic>{
      'displayName': displayName.trim(),
      'email': email.trim(),
      'role': normalizedRole,
      'active': active,
      'updatedAt': now,
    };
    final current = await _usersCol.doc(userId).get().timeout(_opTimeout);
    if (!current.exists) {
      payload['createdAt'] = now;
    }
    await _usersCol
        .doc(userId)
        .set(payload, SetOptions(merge: true))
        .timeout(_opTimeout);

    await _safeLogAudit(
      action: 'USER_UPSERT',
      entityType: 'user',
      entityId: userId,
      message: 'Upserted user $displayName ($normalizedRole)',
      actorName: actorName,
      actorRole: actorRole,
      payload: payload,
    );
  }

  Future<void> setUserRole(
    String userId,
    String role, {
    String actorName = 'System',
    String actorRole = roleAdmin,
  }) async {
    final normalizedRole = normalizeRole(role);
    await _usersCol
        .doc(userId)
        .update({'role': normalizedRole, 'updatedAt': DateTime.now()})
        .timeout(_opTimeout);
    await _safeLogAudit(
      action: 'USER_ROLE_CHANGE',
      entityType: 'user',
      entityId: userId,
      message: 'Changed user role to $normalizedRole',
      actorName: actorName,
      actorRole: actorRole,
      payload: {'role': normalizedRole},
    );
  }

  Stream<List<AssetAuditLog>> watchAuditLogs({
    int limit = 80,
    String? entityType,
    String? entityId,
  }) {
    Query<Map<String, dynamic>> query = _auditCol.orderBy(
      'createdAt',
      descending: true,
    );
    if (entityType != null && entityType.trim().isNotEmpty) {
      query = query.where('entityType', isEqualTo: entityType.trim());
    }
    if (entityId != null && entityId.trim().isNotEmpty) {
      query = query.where('entityId', isEqualTo: entityId.trim());
    }
    query = query.limit(_clampLimit(limit, max: 300));

    return query.snapshots().map((snap) {
      return snap.docs
          .map((doc) => AssetAuditLog.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> logAudit({
    required String action,
    required String entityType,
    required String entityId,
    required String message,
    required String actorName,
    required String actorRole,
    Map<String, dynamic>? payload,
    String? resolutionKey,
  }) async {
    final normalizedRole = normalizeRole(actorRole);
    final body = <String, dynamic>{
      'action': action.trim().toUpperCase(),
      'entityType': entityType.trim(),
      'entityId': entityId.trim(),
      'message': message.trim(),
      'actorName': actorName.trim().isEmpty ? 'Unknown' : actorName.trim(),
      'actorRole': normalizedRole,
      'resolutionKey': resolutionKey?.trim(),
      'payload': payload ?? <String, dynamic>{},
      'createdAt': DateTime.now(),
    };
    await _auditCol.add(body).timeout(_opTimeout);
  }

  Stream<List<MaintenanceTicket>> watchMaintenanceTickets({
    String? assetId,
    bool openOnly = false,
    int limit = 80,
  }) {
    Query<Map<String, dynamic>> query = _maintenanceCol.orderBy(
      'updatedAt',
      descending: true,
    );
    if (assetId != null && assetId.trim().isNotEmpty) {
      query = query.where('assetId', isEqualTo: assetId.trim());
    }
    if (openOnly) {
      query = query.where(
        'status',
        whereIn: [maintenanceOpen, maintenanceInProgress],
      );
    }
    query = query.limit(_clampLimit(limit, max: 300));

    return query.snapshots().map((snap) {
      return snap.docs
          .map((doc) => MaintenanceTicket.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<String> createMaintenanceTicket({
    required String assetId,
    required String title,
    String description = '',
    String assignedTo = '',
    DateTime? dueAt,
    double? estimatedCost,
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final now = DateTime.now();
    final payload = <String, dynamic>{
      'assetId': assetId.trim(),
      'title': title.trim(),
      'description': description.trim(),
      'status': maintenanceOpen,
      'assignedTo': assignedTo.trim(),
      'dueAt': dueAt,
      'estimatedCost': estimatedCost,
      'openedAt': now,
      'updatedAt': now,
      'closedAt': null,
    };

    final doc = await _maintenanceCol.add(payload).timeout(_opTimeout);

    await updateAssetStatus(
      assetId,
      statusRepair,
      note: title.trim(),
      actorName: actorName,
      actorRole: actorRole,
    );

    await _safeLogAudit(
      action: 'MAINTENANCE_CREATE',
      entityType: 'maintenance',
      entityId: doc.id,
      message: 'Created maintenance ticket for asset $assetId',
      actorName: actorName,
      actorRole: actorRole,
      payload: payload,
    );

    return doc.id;
  }

  Future<void> updateMaintenanceStatus(
    String ticketId,
    String status, {
    String note = '',
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final doc = await _maintenanceCol.doc(ticketId).get().timeout(_opTimeout);
    if (!doc.exists) return;
    final data = doc.data()!;
    final normalizedStatus = normalizeMaintenanceStatus(status);
    final now = DateTime.now();

    await _maintenanceCol
        .doc(ticketId)
        .update({
          'status': normalizedStatus,
          'updatedAt': now,
          'closedAt':
              normalizedStatus == maintenanceDone ||
                  normalizedStatus == maintenanceCancelled
              ? now
              : null,
          'closeNote': note.trim(),
        })
        .timeout(_opTimeout);

    final assetId = (data['assetId'] ?? '').toString();
    if (assetId.isNotEmpty &&
        (normalizedStatus == maintenanceDone ||
            normalizedStatus == maintenanceCancelled)) {
      final openForSameAsset = await _maintenanceCol
          .where('assetId', isEqualTo: assetId)
          .where('status', whereIn: [maintenanceOpen, maintenanceInProgress])
          .limit(1)
          .get()
          .timeout(_opTimeout);
      if (openForSameAsset.docs.isEmpty) {
        await updateAssetStatus(
          assetId,
          statusNormal,
          note: note.isEmpty ? 'Maintenance completed' : note,
          actorName: actorName,
          actorRole: actorRole,
        );
      }
    }

    await _safeLogAudit(
      action: 'MAINTENANCE_STATUS',
      entityType: 'maintenance',
      entityId: ticketId,
      message: 'Maintenance status updated to $normalizedStatus',
      actorName: actorName,
      actorRole: actorRole,
      payload: {'status': normalizedStatus, 'note': note.trim()},
    );
  }

  Stream<List<CheckoutRecord>> watchCheckoutRecords({
    String? assetId,
    bool activeOnly = false,
    int limit = 80,
  }) {
    Query<Map<String, dynamic>> query = _checkoutCol.orderBy(
      'updatedAt',
      descending: true,
    );
    if (assetId != null && assetId.trim().isNotEmpty) {
      query = query.where('assetId', isEqualTo: assetId.trim());
    }
    if (activeOnly) {
      query = query.where(
        'status',
        whereIn: [checkoutCheckedOut, checkoutOverdue],
      );
    }
    query = query.limit(_clampLimit(limit, max: 300));
    return query.snapshots().map((snap) {
      return snap.docs
          .map((d) => CheckoutRecord.fromMap(d.id, d.data()))
          .toList();
    });
  }

  Future<CheckoutRecord?> getActiveCheckoutForAsset(String assetId) async {
    final snap = await _checkoutCol
        .where('assetId', isEqualTo: assetId.trim())
        .where('status', whereIn: [checkoutCheckedOut, checkoutOverdue])
        .limit(1)
        .get()
        .timeout(_opTimeout);
    if (snap.docs.isEmpty) return null;
    return CheckoutRecord.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  Future<String> checkoutAsset({
    required String assetId,
    required String borrowerName,
    String borrowerContact = '',
    String purpose = '',
    DateTime? dueAt,
    String note = '',
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final active = await getActiveCheckoutForAsset(assetId);
    if (active != null) {
      throw Exception('This asset is already checked out');
    }

    final now = DateTime.now();
    final status = dueAt != null && dueAt.isBefore(now)
        ? checkoutOverdue
        : checkoutCheckedOut;
    final payload = <String, dynamic>{
      'assetId': assetId.trim(),
      'borrowerName': borrowerName.trim(),
      'borrowerContact': borrowerContact.trim(),
      'purpose': purpose.trim(),
      'status': status,
      'note': note.trim(),
      'checkoutAt': now,
      'dueAt': dueAt,
      'returnedAt': null,
      'updatedAt': now,
    };

    final doc = await _checkoutCol.add(payload).timeout(_opTimeout);

    await updateAsset(
      assetId,
      {
        'checkoutRecordId': doc.id,
        'currentBorrower': borrowerName.trim(),
        'checkoutDueAt': dueAt,
      },
      actorName: actorName,
      actorRole: actorRole,
    );

    await _safeLogAudit(
      action: 'CHECKOUT_CREATE',
      entityType: 'checkout',
      entityId: doc.id,
      message: 'Checked out asset $assetId to ${borrowerName.trim()}',
      actorName: actorName,
      actorRole: actorRole,
      payload: payload,
    );

    if (status == checkoutOverdue) {
      await createNotification(
        type: 'CHECKOUT_OVERDUE',
        title: 'Checkout overdue',
        message: 'Checkout is already overdue for $borrowerName',
        level: notificationWarn,
        assetId: assetId,
        relatedId: doc.id,
        dueAt: dueAt,
        resolutionKey: 'checkout_overdue|${doc.id}',
        actorName: actorName,
        actorRole: actorRole,
      );
    }

    return doc.id;
  }

  Future<void> returnAssetById(
    String checkoutId, {
    String note = '',
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final doc = await _checkoutCol.doc(checkoutId).get().timeout(_opTimeout);
    if (!doc.exists) return;
    final data = doc.data()!;
    final currentStatus = normalizeCheckoutStatus(
      (data['status'] ?? '').toString(),
    );
    if (currentStatus == checkoutReturned) return;

    final now = DateTime.now();
    await _checkoutCol
        .doc(checkoutId)
        .update({
          'status': checkoutReturned,
          'returnedAt': now,
          'updatedAt': now,
          'note': note.trim().isEmpty ? (data['note'] ?? '') : note.trim(),
        })
        .timeout(_opTimeout);

    final assetId = (data['assetId'] ?? '').toString();
    if (assetId.isNotEmpty) {
      await updateAsset(
        assetId,
        {
          'checkoutRecordId': FieldValue.delete(),
          'currentBorrower': FieldValue.delete(),
          'checkoutDueAt': FieldValue.delete(),
        },
        actorName: actorName,
        actorRole: actorRole,
      );
    }

    await _resolveNotificationsByResolutionKey('checkout_overdue|$checkoutId');

    await _safeLogAudit(
      action: 'CHECKOUT_RETURN',
      entityType: 'checkout',
      entityId: checkoutId,
      message: 'Returned checkout $checkoutId',
      actorName: actorName,
      actorRole: actorRole,
      payload: {'note': note.trim(), 'assetId': assetId},
    );
  }

  Future<int> refreshOverdueCheckouts({
    String actorName = 'System',
    String actorRole = roleAdmin,
  }) async {
    final now = DateTime.now();
    final snap = await _checkoutCol
        .where('status', isEqualTo: checkoutCheckedOut)
        .limit(500)
        .get()
        .timeout(_opTimeout);
    var updated = 0;
    for (final doc in snap.docs) {
      final record = CheckoutRecord.fromMap(doc.id, doc.data());
      if (record.dueAt == null || !record.dueAt!.isBefore(now)) continue;

      await _checkoutCol
          .doc(doc.id)
          .update({'status': checkoutOverdue, 'updatedAt': now})
          .timeout(_opTimeout);
      await createNotification(
        type: 'CHECKOUT_OVERDUE',
        title: 'Checkout overdue',
        message:
            'Asset ${record.assetId} is overdue (borrower: ${record.borrowerName})',
        level: notificationWarn,
        assetId: record.assetId,
        relatedId: record.id,
        dueAt: record.dueAt,
        resolutionKey: 'checkout_overdue|${record.id}',
        actorName: actorName,
        actorRole: actorRole,
      );
      updated++;
    }
    return updated;
  }

  Stream<List<StocktakeSession>> watchStocktakeSessions({
    bool openOnly = false,
    int limit = 30,
  }) {
    Query<Map<String, dynamic>> query = _stocktakeCol.orderBy(
      'updatedAt',
      descending: true,
    );
    if (openOnly) {
      query = query.where('status', isEqualTo: stocktakeOpen);
    }
    query = query.limit(_clampLimit(limit, max: 200));
    return query.snapshots().map((snap) {
      return snap.docs
          .map((d) => StocktakeSession.fromMap(d.id, d.data()))
          .toList();
    });
  }

  Future<int> _countTargetAssets(String location) async {
    final normalizedLocation = location.trim();
    Query<Map<String, dynamic>> query = _col.where(
      'status',
      isNotEqualTo: statusDisposed,
    );
    if (normalizedLocation.isNotEmpty) {
      query = query.where('location', isEqualTo: normalizedLocation);
    }
    final snap = await query.limit(5000).get().timeout(_opTimeout);
    return snap.docs.length;
  }

  Future<String> startStocktakeSession({
    required String name,
    String location = '',
    String createdBy = '',
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final now = DateTime.now();
    final targetCount = await _countTargetAssets(location);
    final payload = <String, dynamic>{
      'name': name.trim(),
      'location': location.trim(),
      'status': stocktakeOpen,
      'createdBy': createdBy.trim(),
      'scannedAssetIds': <String>[],
      'totalTargetCount': targetCount,
      'missingCount': targetCount,
      'startedAt': now,
      'endedAt': null,
      'updatedAt': now,
    };
    final doc = await _stocktakeCol.add(payload).timeout(_opTimeout);
    await _safeLogAudit(
      action: 'STOCKTAKE_START',
      entityType: 'stocktake',
      entityId: doc.id,
      message: 'Started stocktake ${name.trim()}',
      actorName: actorName,
      actorRole: actorRole,
      payload: payload,
    );
    return doc.id;
  }

  Future<void> _refreshStocktakeMetrics(String sessionId) async {
    final doc = await _stocktakeCol.doc(sessionId).get().timeout(_opTimeout);
    if (!doc.exists) return;
    final data = doc.data()!;
    final scanned = (data['scannedAssetIds'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toSet();
    var totalTarget = int.tryParse('${data['totalTargetCount'] ?? 0}') ?? 0;
    if (totalTarget <= 0) {
      totalTarget = await _countTargetAssets(
        (data['location'] ?? '').toString(),
      );
    }
    final missing = math.max(0, totalTarget - scanned.length);
    await _stocktakeCol
        .doc(sessionId)
        .update({
          'totalTargetCount': totalTarget,
          'missingCount': missing,
          'updatedAt': DateTime.now(),
        })
        .timeout(_opTimeout);
  }

  Future<void> recordStocktakeScan({
    required String sessionId,
    required String scannedText,
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final code = extractAssetCode(scannedText);
    if (code.isEmpty) throw Exception('Invalid asset code');

    final asset = await getByAssetCode(code);
    if (asset == null) throw Exception('Asset not found');

    final sessionRef = _stocktakeCol.doc(sessionId);
    await _db.runTransaction((txn) async {
      final snap = await txn.get(sessionRef);
      if (!snap.exists) throw Exception('Stocktake session not found');
      final status = (snap.data()?['status'] ?? '').toString().toUpperCase();
      if (status != stocktakeOpen) {
        throw Exception('Stocktake is already closed');
      }
      txn.update(sessionRef, {
        'scannedAssetIds': FieldValue.arrayUnion([asset.id]),
        'updatedAt': DateTime.now(),
      });
    });

    await markAssetScanned(
      asset.id,
      actorName: actorName,
      actorRole: actorRole,
    );
    await _refreshStocktakeMetrics(sessionId);

    await _safeLogAudit(
      action: 'STOCKTAKE_SCAN',
      entityType: 'stocktake',
      entityId: sessionId,
      message: 'Scanned asset ${asset.assetCode} in stocktake',
      actorName: actorName,
      actorRole: actorRole,
      payload: {'assetId': asset.id, 'assetCode': asset.assetCode},
    );
  }

  Future<void> closeStocktakeSession(
    String sessionId, {
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    await _refreshStocktakeMetrics(sessionId);
    await _stocktakeCol
        .doc(sessionId)
        .update({
          'status': stocktakeClosed,
          'endedAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        })
        .timeout(_opTimeout);

    await _safeLogAudit(
      action: 'STOCKTAKE_CLOSE',
      entityType: 'stocktake',
      entityId: sessionId,
      message: 'Closed stocktake session',
      actorName: actorName,
      actorRole: actorRole,
    );
  }

  Stream<List<SystemNotification>> watchNotifications({
    bool unresolvedOnly = true,
    int limit = 80,
  }) {
    Query<Map<String, dynamic>> query = _notificationCol.orderBy(
      'createdAt',
      descending: true,
    );
    if (unresolvedOnly) {
      query = query.where(
        'status',
        whereIn: [notificationNew, notificationRead],
      );
    }
    query = query.limit(_clampLimit(limit, max: 300));
    return query.snapshots().map((snap) {
      return snap.docs
          .map((doc) => SystemNotification.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<int> watchOpenNotificationCount() {
    return watchNotifications(unresolvedOnly: true, limit: 200).map((items) {
      return items.length;
    });
  }

  Future<String> createNotification({
    required String type,
    required String title,
    required String message,
    String level = notificationInfo,
    String? assetId,
    String? relatedId,
    DateTime? dueAt,
    String? resolutionKey,
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final payload = <String, dynamic>{
      'type': type.trim().toUpperCase(),
      'title': title.trim(),
      'message': message.trim(),
      'level': normalizeNotificationLevel(level),
      'status': notificationNew,
      'assetId': assetId?.trim(),
      'relatedId': relatedId?.trim(),
      'dueAt': dueAt,
      'resolutionKey': resolutionKey?.trim(),
      'createdAt': DateTime.now(),
      'readAt': null,
    };
    final doc = await _notificationCol.add(payload).timeout(_opTimeout);
    await _safeLogAudit(
      action: 'NOTIFICATION_CREATE',
      entityType: 'notification',
      entityId: doc.id,
      message: 'Created notification ${title.trim()}',
      actorName: actorName,
      actorRole: actorRole,
      payload: payload,
      resolutionKey: resolutionKey,
    );
    return doc.id;
  }

  Future<void> markNotificationRead(
    String notificationId, {
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    await _notificationCol
        .doc(notificationId)
        .update({'status': notificationRead, 'readAt': DateTime.now()})
        .timeout(_opTimeout);
    await _safeLogAudit(
      action: 'NOTIFICATION_READ',
      entityType: 'notification',
      entityId: notificationId,
      message: 'Marked notification as read',
      actorName: actorName,
      actorRole: actorRole,
    );
  }

  Future<void> resolveNotification(
    String notificationId, {
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    await _notificationCol
        .doc(notificationId)
        .update({'status': notificationResolved, 'readAt': DateTime.now()})
        .timeout(_opTimeout);
    await _safeLogAudit(
      action: 'NOTIFICATION_RESOLVE',
      entityType: 'notification',
      entityId: notificationId,
      message: 'Resolved notification',
      actorName: actorName,
      actorRole: actorRole,
    );
  }

  Future<void> _resolveNotificationsByResolutionKey(String key) async {
    final snap = await _notificationCol
        .where('resolutionKey', isEqualTo: key)
        .where('status', whereIn: [notificationNew, notificationRead])
        .get()
        .timeout(_opTimeout);
    for (final doc in snap.docs) {
      await _notificationCol
          .doc(doc.id)
          .update({'status': notificationResolved, 'readAt': DateTime.now()})
          .timeout(_opTimeout);
    }
  }

  Future<int> generateSystemNotifications({
    int staleScanDays = 90,
    String actorName = 'System',
    String actorRole = roleAdmin,
  }) async {
    final now = DateTime.now();
    final staleBefore = now.subtract(Duration(days: staleScanDays));

    final existingOpen = await _notificationCol
        .where('status', whereIn: [notificationNew, notificationRead])
        .limit(1000)
        .get()
        .timeout(_opTimeout);
    final existingKeys = existingOpen.docs
        .map((d) => (d.data()['resolutionKey'] ?? '').toString())
        .where((k) => k.isNotEmpty)
        .toSet();

    final pendingNotifications = <Map<String, dynamic>>[];

    final assetsSnap = await _col.limit(2000).get().timeout(_opTimeout);
    for (final doc in assetsSnap.docs) {
      final asset = AssetItem.fromMap(doc.id, doc.data());
      if (asset.lastScannedAt == null ||
          asset.lastScannedAt!.isBefore(staleBefore)) {
        final key = 'stale_scan|${asset.id}';
        if (existingKeys.add(key)) {
          pendingNotifications.add({
            'type': 'STALE_SCAN',
            'title': 'Asset not scanned recently',
            'message':
                'Asset ${asset.assetCode} has not been scanned within $staleScanDays days',
            'level': notificationWarn,
            'status': notificationNew,
            'assetId': asset.id,
            'relatedId': null,
            'dueAt': staleBefore,
            'resolutionKey': key,
            'createdAt': now,
            'readAt': null,
          });
        }
      }
    }

    final maintenanceSnap = await _maintenanceCol
        .where('status', whereIn: [maintenanceOpen, maintenanceInProgress])
        .limit(1000)
        .get()
        .timeout(_opTimeout);
    for (final doc in maintenanceSnap.docs) {
      final ticket = MaintenanceTicket.fromMap(doc.id, doc.data());
      if (ticket.dueAt == null || !ticket.dueAt!.isBefore(now)) continue;
      final key = 'maintenance_overdue|${ticket.id}';
      if (existingKeys.add(key)) {
        pendingNotifications.add({
          'type': 'MAINTENANCE_OVERDUE',
          'title': 'Maintenance overdue',
          'message':
              'Maintenance ticket ${ticket.title} for asset ${ticket.assetId} is overdue',
          'level': notificationCritical,
          'status': notificationNew,
          'assetId': ticket.assetId,
          'relatedId': ticket.id,
          'dueAt': ticket.dueAt,
          'resolutionKey': key,
          'createdAt': now,
          'readAt': null,
        });
      }
    }

    final checkoutSnap = await _checkoutCol
        .where('status', whereIn: [checkoutCheckedOut, checkoutOverdue])
        .limit(1000)
        .get()
        .timeout(_opTimeout);
    for (final doc in checkoutSnap.docs) {
      final record = CheckoutRecord.fromMap(doc.id, doc.data());
      if (record.dueAt == null || !record.dueAt!.isBefore(now)) continue;
      final key = 'checkout_overdue|${record.id}';
      if (existingKeys.add(key)) {
        pendingNotifications.add({
          'type': 'CHECKOUT_OVERDUE',
          'title': 'Checkout overdue',
          'message':
              'Asset ${record.assetId} checked out to ${record.borrowerName} is overdue',
          'level': notificationWarn,
          'status': notificationNew,
          'assetId': record.assetId,
          'relatedId': record.id,
          'dueAt': record.dueAt,
          'resolutionKey': key,
          'createdAt': now,
          'readAt': null,
        });
      }
    }

    if (pendingNotifications.isEmpty) return 0;

    final batch = _db.batch();
    for (final body in pendingNotifications) {
      final ref = _notificationCol.doc();
      batch.set(ref, body);
    }
    await batch.commit().timeout(_opTimeout);

    await _safeLogAudit(
      action: 'NOTIFICATION_GENERATE',
      entityType: 'notification',
      entityId: 'bulk',
      message: 'Generated ${pendingNotifications.length} system notifications',
      actorName: actorName,
      actorRole: actorRole,
      payload: {'count': pendingNotifications.length},
    );

    return pendingNotifications.length;
  }

  Stream<List<AssetAttachment>> watchAttachments(
    String assetId, {
    int limit = 100,
  }) {
    final safeLimit = _clampLimit(limit, max: 500);
    return _attachmentCol
        .where('assetId', isEqualTo: assetId)
        .orderBy('createdAt', descending: true)
        .limit(safeLimit)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => AssetAttachment.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  Future<String> addAttachment({
    required String assetId,
    required String name,
    required String url,
    String fileType = 'LINK',
    String note = '',
    String createdBy = '',
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final payload = <String, dynamic>{
      'assetId': assetId.trim(),
      'name': name.trim(),
      'fileType': fileType.trim().toUpperCase(),
      'url': url.trim(),
      'note': note.trim(),
      'createdBy': createdBy.trim(),
      'createdAt': DateTime.now(),
    };
    final doc = await _attachmentCol.add(payload).timeout(_opTimeout);
    await _safeLogAudit(
      action: 'ATTACHMENT_ADD',
      entityType: 'attachment',
      entityId: doc.id,
      message: 'Added attachment ${name.trim()} to asset $assetId',
      actorName: actorName,
      actorRole: actorRole,
      payload: payload,
    );
    return doc.id;
  }

  Future<void> removeAttachment(
    String attachmentId, {
    String actorName = 'System',
    String actorRole = roleStaff,
  }) async {
    final doc = await _attachmentCol
        .doc(attachmentId)
        .get()
        .timeout(_opTimeout);
    if (!doc.exists) return;
    final data = doc.data()!;
    await _attachmentCol.doc(attachmentId).delete().timeout(_opTimeout);
    await _safeLogAudit(
      action: 'ATTACHMENT_REMOVE',
      entityType: 'attachment',
      entityId: attachmentId,
      message: 'Removed attachment ${data['name'] ?? attachmentId}',
      actorName: actorName,
      actorRole: actorRole,
      payload: {'assetId': data['assetId'], 'name': data['name']},
    );
  }

  String _escapeCsv(String value) {
    final needsQuote =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    if (!needsQuote) return value;
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _dateToCsv(DateTime? value) => value?.toIso8601String() ?? '';

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    result.add(buffer.toString());
    return result;
  }

  DateTime? _tryParseDate(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  Future<String> exportAssetsCsv({
    AssetSearchFilter filter = const AssetSearchFilter(),
    int limit = 2000,
  }) async {
    final items = await searchAssetsAdvanced(filter, limit: limit);
    final rows = <String>[];
    rows.add(
      [
        'assetCode',
        'type',
        'brand',
        'detail',
        'location',
        'status',
        'statusNote',
        'currentBorrower',
        'checkoutDueAt',
        'lastScannedAt',
        'createdAt',
        'updatedAt',
      ].join(','),
    );

    for (final item in items) {
      rows.add(
        [
          _escapeCsv(item.assetCode),
          _escapeCsv(item.type),
          _escapeCsv(item.brand),
          _escapeCsv(item.detail),
          _escapeCsv(item.location),
          _escapeCsv(item.status),
          _escapeCsv(item.statusNote ?? ''),
          _escapeCsv(item.currentBorrower ?? ''),
          _escapeCsv(_dateToCsv(item.checkoutDueAt)),
          _escapeCsv(_dateToCsv(item.lastScannedAt)),
          _escapeCsv(_dateToCsv(item.createdAt)),
          _escapeCsv(_dateToCsv(item.updatedAt)),
        ].join(','),
      );
    }

    return rows.join('\n');
  }

  Future<CsvImportResult> importAssetsFromCsv(
    String csv, {
    bool overwriteExisting = false,
    String actorName = 'System',
    String actorRole = roleAdmin,
  }) async {
    final lines = csv
        .replaceAll('\r\n', '\n')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const CsvImportResult(
        imported: 0,
        updated: 0,
        skipped: 0,
        errors: ['CSV is empty'],
      );
    }

    final headers = _parseCsvLine(
      lines.first,
    ).map((h) => h.trim().toLowerCase()).toList();
    final headerIndex = <String, int>{};
    for (var i = 0; i < headers.length; i++) {
      headerIndex[headers[i]] = i;
    }

    int? idx(String key) => headerIndex[key];

    int? codeIndex = idx('assetcode') ?? idx('asset_code') ?? idx('code');
    if (codeIndex == null) {
      return const CsvImportResult(
        imported: 0,
        updated: 0,
        skipped: 0,
        errors: ['CSV header must include assetCode or code'],
      );
    }

    int imported = 0;
    int updated = 0;
    int skipped = 0;
    final errors = <String>[];

    String readCell(List<String> row, int? index) {
      if (index == null || index < 0 || index >= row.length) return '';
      return row[index].trim();
    }

    for (var lineNumber = 2; lineNumber <= lines.length; lineNumber++) {
      final row = _parseCsvLine(lines[lineNumber - 1]);
      final rawCode = readCell(row, codeIndex);
      final code = normalizeAssetCode(rawCode);
      if (code.isEmpty) {
        errors.add('Line $lineNumber: missing assetCode');
        skipped++;
        continue;
      }

      final data = <String, dynamic>{
        'assetCode': code,
        'type': readCell(row, idx('type')),
        'brand': readCell(row, idx('brand')),
        'detail': readCell(row, idx('detail')),
        'location': readCell(row, idx('location')),
        'status': normalizeStatus(readCell(row, idx('status'))),
        'statusNote': readCell(row, idx('statusnote')),
        'currentBorrower': readCell(row, idx('currentborrower')),
      };

      final checkoutDueAt = _tryParseDate(readCell(row, idx('checkoutdueat')));
      final lastScannedAt = _tryParseDate(readCell(row, idx('lastscannedat')));
      if (checkoutDueAt != null) data['checkoutDueAt'] = checkoutDueAt;
      if (lastScannedAt != null) data['lastScannedAt'] = lastScannedAt;

      try {
        final existing = await getByAssetCode(code);
        if (existing == null) {
          await createAssetWithId(
            newAssetId(),
            data,
            actorName: actorName,
            actorRole: actorRole,
          );
          imported++;
          continue;
        }

        if (!overwriteExisting) {
          skipped++;
          continue;
        }

        await updateAsset(
          existing.id,
          data,
          actorName: actorName,
          actorRole: actorRole,
        );
        updated++;
      } catch (e) {
        errors.add('Line $lineNumber: $e');
      }
    }

    await _safeLogAudit(
      action: 'CSV_IMPORT',
      entityType: 'asset',
      entityId: 'bulk',
      message:
          'CSV import complete (imported: $imported, updated: $updated, skipped: $skipped)',
      actorName: actorName,
      actorRole: actorRole,
      payload: {
        'imported': imported,
        'updated': updated,
        'skipped': skipped,
        'errors': errors.length,
      },
    );

    return CsvImportResult(
      imported: imported,
      updated: updated,
      skipped: skipped,
      errors: errors,
    );
  }
}
