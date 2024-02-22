library simple_http_extension;

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class HttpEx {
  final logger = Logger();
  final Map<String, int> _expirationTimestamp = {};
  final Map<String, dynamic> _localInMemCache = {};
  final Set<String> _mustRevalidate = {};

  /// Performs an HTTP GET request to the specified [url].
  ///
  /// This method implements caching and revalidation logic based on the `max-age`
  /// and `must-revalidate` headers in the HTTP response. If the URL is in the
  /// `_mustRevalidate` set, a new request is made and the cache is updated.
  /// If the URL is not in the set, the method checks if the cached response
  /// has expired and returns it if it hasn't. If the URL is not cached or
  /// has expired, a new request is made and the cache is updated.
  ///
  /// Throws an [Exception] if the HTTP request fails.
  Future<dynamic> get(String url) async {
    if (_mustRevalidate.contains(url) ||
        !_expirationTimestamp.containsKey(url)) {
      return getImplementation(url);
    }
    int nowInSeconds = DateTime.now().millisecondsSinceEpoch;
    if (_expirationTimestamp.containsKey(url) &&
        _expirationTimestamp[url]! > nowInSeconds) {
      logger.d('Find cached data at $url');
      return _localInMemCache[url];
    }

    logger.d('Cached data at $url is expired');
    _expirationTimestamp.remove(url);
    _localInMemCache.remove(url);
    _mustRevalidate.remove(url);

    return getImplementation(url);
  }

  /// Performs an HTTP GET request to the specified [url] without considering
  /// local cache and expiration time.
  ///
  /// This method makes a new HTTP request to the specified [url] without
  /// checking the cache or the expiration time. The response is not cached,
  /// and no revalidation logic is applied.
  ///
  /// Throws an [Exception] if the HTTP request fails.
  Future<dynamic> forceGet(String url) async {
    return getImplementation(url);
  }

  Future<dynamic> getImplementation(String url) async {
    logger.d("start getting $url");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _expirationTimestamp.remove(url);
        _localInMemCache.remove(url);
        _mustRevalidate.remove(url);
        if (response.headers.containsKey('cache-control')) {
          String cacheControlHeader = response.headers['cache-control']!;
          RegExp regExp = RegExp(r'max-age=(\d+)');
          Match? match = regExp.firstMatch(cacheControlHeader);
          if (match != null) {
            String maxAgeString = match.group(1)!;
            int maxAge = int.parse(maxAgeString);
            _expirationTimestamp[url] =
                maxAge * 1000 + DateTime.now().millisecondsSinceEpoch;
            _localInMemCache[url] = response.body;
          }
          regExp = RegExp(r'must-revalidate');
          match = regExp.firstMatch(cacheControlHeader);
          if (match != null) {
            _mustRevalidate.add(url);
          }
        }
        return response.body;
      } else {
        return '${response.statusCode}';
      }
    } catch (e) {
      throw Exception('$e');
    }
  }
}
