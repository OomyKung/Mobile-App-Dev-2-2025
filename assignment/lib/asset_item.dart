class AssetItem {
  final String id;
  final String assetCode;
  final String type;
  final String brand;
  final String detail;
  final String location;
  final String status; // NORMAL, REPAIR, DISPOSED
  final String? imageUrl;
  final String? imageBase64;
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
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.imageBase64,
  });

  static DateTime _toDt(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    // Firestore Timestamp
    return (v as dynamic).toDate();
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

  factory AssetItem.fromMap(String id, Map<String, dynamic> data) {
    return AssetItem(
      id: id,
      assetCode: (data['assetCode'] ?? '').toString(),
      type: (data['type'] ?? '').toString(),
      brand: (data['brand'] ?? '').toString(),
      detail: (data['detail'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      status: (data['status'] ?? 'NORMAL').toString(),
      imageUrl: _readImageUrl(data),
      imageBase64: _readImageBase64(data),
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
    'imageUrl': imageUrl,
    'imageBase64': imageBase64,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
