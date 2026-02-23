import 'package:cloud_firestore/cloud_firestore.dart';
import 'asset_item.dart';

class AssetService {
  final _col = FirebaseFirestore.instance.collection('assets');
  static const _opTimeout = Duration(seconds: 15);

  String newAssetId() => _col.doc().id;

  Stream<List<AssetItem>> watchAll() {
    return _col.orderBy('updatedAt', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) => AssetItem.fromMap(d.id, d.data())).toList();
    });
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

  Future<AssetItem?> getByAssetCode(String code) async {
    final q = await _col
        .where('assetCode', isEqualTo: code)
        .limit(1)
        .get()
        .timeout(_opTimeout);
    if (q.docs.isEmpty) return null;
    final d = q.docs.first;
    return AssetItem.fromMap(d.id, d.data());
  }

  Future<bool> assetCodeExists(String code, {String? exceptId}) async {
    final q = await _col
        .where('assetCode', isEqualTo: code)
        .limit(5)
        .get()
        .timeout(_opTimeout);
    if (q.docs.isEmpty) return false;
    if (exceptId == null) return true;
    return q.docs.any((d) => d.id != exceptId);
  }

  Future<String> createAsset(Map<String, dynamic> data) async {
    final now = DateTime.now();
    data['createdAt'] = now;
    data['updatedAt'] = now;
    final doc = await _col.add(data).timeout(_opTimeout);
    return doc.id;
  }

  Future<void> createAssetWithId(String id, Map<String, dynamic> data) async {
    final now = DateTime.now();
    data['createdAt'] = now;
    data['updatedAt'] = now;
    await _col.doc(id).set(data).timeout(_opTimeout);
  }

  Future<void> updateAsset(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = DateTime.now();
    await _col.doc(id).update(data).timeout(_opTimeout);
  }

  Future<void> deleteAsset(String id) async {
    await _col.doc(id).delete().timeout(_opTimeout);
  }
}
