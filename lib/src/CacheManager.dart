import 'package:cloud_firestore/cloud_firestore.dart';

class CacheManager {
  Map<String, DocumentSnapshot> _cache;
  static List<CacheManagerListener> _listeners = [];

  CacheManager() {
    _cache = {};
  }

  void addCache(DocumentSnapshot doc) {
    if (_cache[doc.reference.path] != null) {
      _listeners.forEach(
          (listener) => listener.onCacheUpdate?.call(doc.reference.path, doc));
    } else {
      _listeners.forEach(
          (listener) => listener.onCacheAdd?.call(doc.reference.path, doc));
    }

    _cache[doc.reference.path] = doc;
  }

  DocumentSnapshot getCache(String path) {
    DocumentSnapshot doc = _cache[path];

    _listeners.forEach((listener) {
      listener.onCacheRequest?.call(path);

      if (doc != null)
        listener.onCacheHit?.call(path, doc);
      else
        listener.onCacheMiss?.call(path);
    });
    return doc;
  }

  static void addListener(CacheManagerListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(CacheManagerListener listener) {
    _listeners.remove(listener);
  }

  static void removeAllListeners() {
    _listeners.clear();
  }
}

class CacheManagerListener {
  void Function(String path, DocumentSnapshot doc) onCacheHit;
  void Function(String path) onCacheMiss;
  void Function(String path, DocumentSnapshot doc) onCacheAdd;
  void Function(String path, DocumentSnapshot doc) onCacheUpdate;
  void Function(String path) onCacheRequest;

  CacheManagerListener({
    this.onCacheHit,
    this.onCacheMiss,
    this.onCacheAdd,
    this.onCacheUpdate,
    this.onCacheRequest,
  });
}
