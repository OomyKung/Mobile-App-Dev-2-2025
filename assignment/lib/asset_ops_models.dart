class AssetSearchFilter {
  final String keyword;
  final String status;
  final String type;
  final String brand;
  final String location;
  final bool onlyNeverScanned;
  final bool onlyCheckedOut;
  final DateTime? updatedFrom;
  final DateTime? updatedTo;

  const AssetSearchFilter({
    this.keyword = '',
    this.status = 'ALL',
    this.type = '',
    this.brand = '',
    this.location = '',
    this.onlyNeverScanned = false,
    this.onlyCheckedOut = false,
    this.updatedFrom,
    this.updatedTo,
  });
}

class CsvImportResult {
  final int imported;
  final int updated;
  final int skipped;
  final List<String> errors;

  const CsvImportResult({
    required this.imported,
    required this.updated,
    required this.skipped,
    required this.errors,
  });
}

DateTime _toDateTime(dynamic v, {DateTime? fallback}) {
  if (v == null) return fallback ?? DateTime.now();
  if (v is DateTime) return v;
  if (v is String && v.trim().isNotEmpty) {
    final parsed = DateTime.tryParse(v.trim());
    if (parsed != null) return parsed;
  }
  return (v as dynamic).toDate();
}

DateTime? _toNullableDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String && v.trim().isNotEmpty) {
    return DateTime.tryParse(v.trim());
  }
  try {
    return (v as dynamic).toDate();
  } catch (_) {
    return null;
  }
}

String _toText(dynamic v) => (v ?? '').toString().trim();

String? _toNullableText(dynamic v) {
  final text = _toText(v);
  if (text.isEmpty) return null;
  return text;
}

double? _toNullableDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().trim());
}

bool _toBool(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  final text = v?.toString().trim().toLowerCase();
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return fallback;
}

List<String> _toStringList(dynamic v) {
  if (v is List) {
    return v
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }
  return const [];
}

class AssetUserProfile {
  final String id;
  final String displayName;
  final String email;
  final String role;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssetUserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssetUserProfile.fromMap(String id, Map<String, dynamic> data) {
    return AssetUserProfile(
      id: id,
      displayName: _toText(data['displayName']),
      email: _toText(data['email']),
      role: _toText(data['role']).toUpperCase(),
      active: _toBool(data['active'], fallback: true),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'email': email,
    'role': role,
    'active': active,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class AssetAuditLog {
  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String actorName;
  final String actorRole;
  final String message;
  final String? resolutionKey;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const AssetAuditLog({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.actorName,
    required this.actorRole,
    required this.message,
    required this.resolutionKey,
    required this.payload,
    required this.createdAt,
  });

  factory AssetAuditLog.fromMap(String id, Map<String, dynamic> data) {
    final payloadData = data['payload'];
    return AssetAuditLog(
      id: id,
      action: _toText(data['action']).toUpperCase(),
      entityType: _toText(data['entityType']),
      entityId: _toText(data['entityId']),
      actorName: _toText(data['actorName']),
      actorRole: _toText(data['actorRole']).toUpperCase(),
      message: _toText(data['message']),
      resolutionKey: _toNullableText(data['resolutionKey']),
      payload: payloadData is Map<String, dynamic> ? payloadData : const {},
      createdAt: _toDateTime(data['createdAt']),
    );
  }
}

class MaintenanceTicket {
  final String id;
  final String assetId;
  final String title;
  final String description;
  final String status;
  final String assignedTo;
  final double? estimatedCost;
  final DateTime? dueAt;
  final DateTime openedAt;
  final DateTime updatedAt;
  final DateTime? closedAt;

  const MaintenanceTicket({
    required this.id,
    required this.assetId,
    required this.title,
    required this.description,
    required this.status,
    required this.assignedTo,
    required this.estimatedCost,
    required this.dueAt,
    required this.openedAt,
    required this.updatedAt,
    required this.closedAt,
  });

  bool get isOpen => status == 'OPEN' || status == 'IN_PROGRESS';

  factory MaintenanceTicket.fromMap(String id, Map<String, dynamic> data) {
    return MaintenanceTicket(
      id: id,
      assetId: _toText(data['assetId']),
      title: _toText(data['title']),
      description: _toText(data['description']),
      status: _toText(data['status']).toUpperCase(),
      assignedTo: _toText(data['assignedTo']),
      estimatedCost: _toNullableDouble(data['estimatedCost']),
      dueAt: _toNullableDateTime(data['dueAt']),
      openedAt: _toDateTime(data['openedAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      closedAt: _toNullableDateTime(data['closedAt']),
    );
  }
}

class CheckoutRecord {
  final String id;
  final String assetId;
  final String borrowerName;
  final String borrowerContact;
  final String purpose;
  final String status;
  final String note;
  final DateTime checkoutAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;
  final DateTime updatedAt;

  const CheckoutRecord({
    required this.id,
    required this.assetId,
    required this.borrowerName,
    required this.borrowerContact,
    required this.purpose,
    required this.status,
    required this.note,
    required this.checkoutAt,
    required this.dueAt,
    required this.returnedAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'CHECKED_OUT' || status == 'OVERDUE';

  factory CheckoutRecord.fromMap(String id, Map<String, dynamic> data) {
    return CheckoutRecord(
      id: id,
      assetId: _toText(data['assetId']),
      borrowerName: _toText(data['borrowerName']),
      borrowerContact: _toText(data['borrowerContact']),
      purpose: _toText(data['purpose']),
      status: _toText(data['status']).toUpperCase(),
      note: _toText(data['note']),
      checkoutAt: _toDateTime(data['checkoutAt']),
      dueAt: _toNullableDateTime(data['dueAt']),
      returnedAt: _toNullableDateTime(data['returnedAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }
}

class StocktakeSession {
  final String id;
  final String name;
  final String location;
  final String status;
  final String createdBy;
  final List<String> scannedAssetIds;
  final int totalTargetCount;
  final int missingCount;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime? endedAt;

  const StocktakeSession({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.createdBy,
    required this.scannedAssetIds,
    required this.totalTargetCount,
    required this.missingCount,
    required this.startedAt,
    required this.updatedAt,
    required this.endedAt,
  });

  bool get isOpen => status == 'OPEN';

  factory StocktakeSession.fromMap(String id, Map<String, dynamic> data) {
    return StocktakeSession(
      id: id,
      name: _toText(data['name']),
      location: _toText(data['location']),
      status: _toText(data['status']).toUpperCase(),
      createdBy: _toText(data['createdBy']),
      scannedAssetIds: _toStringList(data['scannedAssetIds']),
      totalTargetCount:
          int.tryParse(data['totalTargetCount']?.toString() ?? '') ?? 0,
      missingCount: int.tryParse(data['missingCount']?.toString() ?? '') ?? 0,
      startedAt: _toDateTime(data['startedAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      endedAt: _toNullableDateTime(data['endedAt']),
    );
  }
}

class SystemNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final String level;
  final String status;
  final String? assetId;
  final String? relatedId;
  final String? resolutionKey;
  final DateTime createdAt;
  final DateTime? dueAt;
  final DateTime? readAt;

  const SystemNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.level,
    required this.status,
    required this.assetId,
    required this.relatedId,
    required this.resolutionKey,
    required this.createdAt,
    required this.dueAt,
    required this.readAt,
  });

  bool get isOpen => status == 'NEW' || status == 'READ';

  factory SystemNotification.fromMap(String id, Map<String, dynamic> data) {
    return SystemNotification(
      id: id,
      type: _toText(data['type']).toUpperCase(),
      title: _toText(data['title']),
      message: _toText(data['message']),
      level: _toText(data['level']).toUpperCase(),
      status: _toText(data['status']).toUpperCase(),
      assetId: _toNullableText(data['assetId']),
      relatedId: _toNullableText(data['relatedId']),
      resolutionKey: _toNullableText(data['resolutionKey']),
      createdAt: _toDateTime(data['createdAt']),
      dueAt: _toNullableDateTime(data['dueAt']),
      readAt: _toNullableDateTime(data['readAt']),
    );
  }
}

class AssetAttachment {
  final String id;
  final String assetId;
  final String name;
  final String fileType;
  final String url;
  final String note;
  final String createdBy;
  final DateTime createdAt;

  const AssetAttachment({
    required this.id,
    required this.assetId,
    required this.name,
    required this.fileType,
    required this.url,
    required this.note,
    required this.createdBy,
    required this.createdAt,
  });

  factory AssetAttachment.fromMap(String id, Map<String, dynamic> data) {
    return AssetAttachment(
      id: id,
      assetId: _toText(data['assetId']),
      name: _toText(data['name']),
      fileType: _toText(data['fileType']),
      url: _toText(data['url']),
      note: _toText(data['note']),
      createdBy: _toText(data['createdBy']),
      createdAt: _toDateTime(data['createdAt']),
    );
  }
}

class AppSyncState {
  final bool isFromCache;
  final bool hasPendingWrites;
  final DateTime observedAt;

  const AppSyncState({
    required this.isFromCache,
    required this.hasPendingWrites,
    required this.observedAt,
  });

  String get label {
    if (hasPendingWrites) return 'กำลังซิงก์';
    if (isFromCache) return 'ออฟไลน์ (แคช)';
    return 'ออนไลน์';
  }
}
