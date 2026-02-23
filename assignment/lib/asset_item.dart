class AssetItem {
  final String id;
  final String assetCode;
  final String type;
  final String brand;
  final String detail;
  final String location;
  final String status; // NORMAL, REPAIR, DISPOSED
  final String? imageUrl;
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
  });

  static DateTime _toDt(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    // Firestore Timestamp
    return (v as dynamic).toDate();
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
      imageUrl: data['imageUrl']?.toString(),
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
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
