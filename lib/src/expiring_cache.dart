// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'package:quiver/collection.dart';

/// A cache that holds strong references to a limited number of values for a
/// limited time.
class ExpiringCache<K, V> {
  ExpiringCache([
    this.expirationTimeout = defaultExpirationTimeout,
    int maxSize = defaultMaxSize,
  ]) : _lruCache = LruMap<K, MapEntry<V, DateTime>>(maximumSize: maxSize);

  static const int defaultMaxSize = 64;
  static const Duration defaultExpirationTimeout = Duration(seconds: 120);
  final Duration expirationTimeout; // Time after which a cache entry is invalidated

  final LruMap<K, MapEntry<V, DateTime>> _lruCache;

  /// Puts a value in the cache, computing an expiration time
  ///
  /// Return the previous value for this key, if any
  void operator []=(K key, V value) {
    final DateTime timeout = DateTime.now().add(expirationTimeout);
    _lruCache[key] = MapEntry<V, DateTime>(value, timeout);
  }

  /// Get a value from the cache
  ///
  /// Returns the cached value if it is still valid, else null.
  V operator [](K key) {
    final MapEntry<V, DateTime> cachePair = _lruCache[key];
    if (cachePair != null && cachePair.key != null) {
      if (cachePair.value.compareTo(DateTime.now()) > 0) {
        return cachePair.key;
      } else {
        _lruCache.remove(key);
      }
    }
    return null;
  }

  /// Returns the number of entries in the cache.
  int get length => _lruCache.length;

  /// Reset the cache, keeping the current settings.
  void clear() => _lruCache.clear();
}
