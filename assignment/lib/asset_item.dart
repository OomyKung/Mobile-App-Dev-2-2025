class AssetItem {
  final String id;
  final String assetCode;
  final String type;
  final String brand;
  final String detail;
  final String location;
  final String status; // NORMAL, REPAIR, DISPOSED, BORROWED, LOST
  final String? statusNote;
  final String? checkoutRecordId;
  final String? currentBorrower;
  final DateTime? checkoutDueAt;
  final String? imageUrl;
  final String? imageBase64;
  final DateTime? lastScannedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssetItem({
    required this.id,
    required this.assetCode,
    required this.type,
    required this.brand,
    required this.detail,
    required this.location,
    required this.status,
    this.statusNote,
    this.checkoutRecordId,
    this.currentBorrower,
    this.checkoutDueAt,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.imageBase64,
    this.lastScannedAt,
  });

  bool get isCheckedOut =>
      checkoutRecordId != null && checkoutRecordId!.trim().isNotEmpty;

  // Support both new model (status = BORROWED) and legacy checkout linkage.
  bool get isBorrowed =>
      status.trim().toUpperCase() == 'BORROWED' || isCheckedOut;

  static DateTime _toDt(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    // Firestore Timestamp
    return (v as dynamic).toDate();
  }

  static DateTime? _toNullableDt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    try {
      return (v as dynamic).toDate();
    } catch (_) {
      return null;
    }
  }

  static String? _toNonEmptyString(dynamic v) {
    final text = v?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static String? _readImageUrl(Map<String, dynamic> data) {
    const keys = [
      'imageUrl',
      'imageURL',
      'image',
      'photoUrl',
      'photoURL',
      'url',
    ];
    for (final key in keys) {
      final value = _toNonEmptyString(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  static String? _readImageBase64(Map<String, dynamic> data) {
    const keys = [
      'imageBase64',
      'image_base64',
      'imageData',
      'photoBase64',
      'photoData',
    ];
    for (final key in keys) {
      final value = _toNonEmptyString(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  static String? _readStatusNote(Map<String, dynamic> data) {
    const keys = ['statusNote', 'status_note', 'note'];
    for (final key in keys) {
      final value = _toNonEmptyString(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  static String? _readCheckoutRecordId(Map<String, dynamic> data) {
    const keys = ['checkoutRecordId', 'checkout_id', 'activeCheckoutId'];
    for (final key in keys) {
      final value = _toNonEmptyString(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  static String? _readCurrentBorrower(Map<String, dynamic> data) {
    const keys = ['currentBorrower', 'borrowerName', 'holder'];
    for (final key in keys) {
      final value = _toNonEmptyString(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  factory AssetItem.fromMap(String id, Map<String, dynamic> data) {
    return AssetItem(
      id: id,
      assetCode: (data['assetCode'] ?? '').toString(),
      type: (data['type'] ?? '').toString(),
      brand: (data['brand'] ?? '').toString(),
      detail: (data['detail'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      status: (data['status'] ?? 'NORMAL').toString().toUpperCase(),
      statusNote: _readStatusNote(data),
      checkoutRecordId: _readCheckoutRecordId(data),
      currentBorrower: _readCurrentBorrower(data),
      checkoutDueAt: _toNullableDt(data['checkoutDueAt']),
      imageUrl: _readImageUrl(data),
      imageBase64: _readImageBase64(data),
      lastScannedAt: _toNullableDt(data['lastScannedAt']),
      createdAt: _toDt(data['createdAt']),
      updatedAt: _toDt(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'assetCode': assetCode,
    'type': type,
    'brand': brand,
    'detail': detail,
    'location': location,
    'status': status,
    'statusNote': statusNote,
    'checkoutRecordId': checkoutRecordId,
    'currentBorrower': currentBorrower,
    'checkoutDueAt': checkoutDueAt,
    'imageUrl': imageUrl,
    'imageBase64': imageBase64,
    'lastScannedAt': lastScannedAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
