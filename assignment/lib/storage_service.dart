import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;
  static const _opTimeout = Duration(seconds: 30);
  static final Map<String, String?> _resolvedUrlCache = {};

  String _mainImagePath(String assetId) => 'assets/$assetId/main.jpg';

  Future<String?> _safeGetDownloadUrl(Reference ref) async {
    try {
      return await ref.getDownloadURL().timeout(_opTimeout);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveFirstFileUrl(String assetId) async {
    try {
      final result = await _storage
          .ref('assets/$assetId')
          .list(const ListOptions(maxResults: 1))
          .timeout(_opTimeout);
      if (result.items.isEmpty) return null;
      return await _safeGetDownloadUrl(result.items.first);
    } catch (_) {
      return null;
    }
  }

  bool _isHttpUrl(String? value) {
    final v = (value ?? '').trim().toLowerCase();
    return v.startsWith('https://') || v.startsWith('http://');
  }

  void _clearImageCache(String assetId) {
    _resolvedUrlCache.removeWhere((key, _) => key.startsWith('$assetId|'));
  }

  Future<String> uploadAssetImage({
    required String assetId,
    required File file,
  }) async {
    final ref = _storage.ref(_mainImagePath(assetId));
    await ref.putFile(file).timeout(_opTimeout);
    final url = await ref.getDownloadURL().timeout(_opTimeout);
    _clearImageCache(assetId);
    return url;
  }

  Future<void> deleteAssetImage(String assetId) async {
    final ref = _storage.ref(_mainImagePath(assetId));
    try {
      await ref.delete().timeout(_opTimeout);
    } catch (_) {
      // ignore (file may not exist)
    } finally {
      _clearImageCache(assetId);
    }
  }

  Future<String?> resolveAssetImageUrl({
    required String assetId,
    String? storedUrl,
  }) async {
    final normalized = storedUrl?.trim();
    final cacheKey = '$assetId|${normalized ?? ''}';
    if (_resolvedUrlCache.containsKey(cacheKey)) {
      return _resolvedUrlCache[cacheKey];
    }

    String? resolvedUrl;

    // Prefer a fresh URL from the canonical image path to avoid stale tokens.
    resolvedUrl = await _safeGetDownloadUrl(_storage.ref(_mainImagePath(assetId)));

    if (resolvedUrl == null &&
        normalized != null &&
        normalized.isNotEmpty &&
        normalized.startsWith('gs://')) {
      resolvedUrl = await _safeGetDownloadUrl(_storage.refFromURL(normalized));
    }

    if (resolvedUrl == null && _isHttpUrl(normalized)) {
      resolvedUrl = normalized;
    }

    resolvedUrl ??= await _resolveFirstFileUrl(assetId);

    _resolvedUrlCache[cacheKey] = resolvedUrl;
    return resolvedUrl;
  }
}
