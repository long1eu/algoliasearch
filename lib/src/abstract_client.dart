// File created by
// Lung Razvan <int1eu>
// on 2018-12-05

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:algoliasearch/src/abstract_query.dart';
import 'package:algoliasearch/src/algolia_exception.dart';
import 'package:algoliasearch/src/request_options.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

enum Method { get, post, put, delete }

/// An abstract API client.
abstract class AbstractClient {
  AbstractClient(this.applicationID, this.apiKey, List<String> readHosts, List<String> writeHosts) {
    addUserAgent(const LibraryVersion('Algolia for Dart', _version));
    addUserAgent(const LibraryVersion('Dart', '2.1.0'));

    if (readHosts != null) {
      this.readHosts = readHosts;
    }
    if (writeHosts != null) {
      this.writeHosts = writeHosts;
    }
  }

  /// This library's version.
  static const String _version = '0.0.1';

  /// Maximum size for an API key to be sent in the HTTP headers. Bigger keys
  /// will go inside the body.
  static const int _maxApiKeyLength = 500;

  final String applicationID;
  final String apiKey;

  /// HTTP headers that will be sent with every request.
  final Map<String, String> _headers = <String, String>{};

  /// The user agents as a raw string. This is what is passed in request
  /// headers.
  /// WARNING: It is stored for efficiency purposes. It should not be
  /// modified directly.
  @visibleForTesting
  String userAgentRaw;

  /// The user agents, as a structured list of library versions.
  List<LibraryVersion> userAgents = <LibraryVersion>[];

  /// Delay to wait when a host is down before retrying it.
  Duration hostDownDelay = Duration(seconds: 5);

  List<String> _readHosts;
  List<String> _writeHosts;

  Map<String, _HostStatus> hostStatuses = <String, _HostStatus>{};

  /// Set an HTTP header that will be sent with every request.
  ///
  /// @param name  Header name.
  /// @param value Value for the header. If null, the header will be removed.
  void setHeader(String name, String value) {
    if (value == null) {
      _headers.remove(name);
    } else {
      _headers[name] = value;
    }
  }

  /// Get an HTTP header.
  ///
  /// Header [name].
  String getHeader(String name) => _headers[name];

  List<String> get readHosts => _readHosts;

  set readHosts(List<String> hosts) {
    if (hosts.isEmpty) {
      throw ArgumentError('Hosts array cannot be empty');
    }
    _readHosts = hosts;
  }

  List<String> get writeHosts => _writeHosts;

  set writeHosts(List<String> hosts) {
    if (hosts.isEmpty) {
      throw ArgumentError('Hosts array cannot be empty');
    }
    _writeHosts = hosts;
  }

  /// Set read and write hosts to the same value (convenience method).
  ///
  /// New [hosts]. Must not be empty.
  // ignore: avoid_setters_without_getters
  set hosts(List<String> hosts) {
    readHosts = hosts;
    writeHosts = hosts;
  }

  /// Add a software library to the list of user agents.
  ///
  /// [userAgent] is the library to add.
  void addUserAgent(LibraryVersion userAgent) {
    if (!userAgents.contains(userAgent)) {
      userAgents.add(userAgent);
    }
    _updateUserAgents();
  }

  /// Remove a software library from the list of user agents.
  ///
  /// [userAgent] is the library to remove.
  void removeUserAgent(LibraryVersion userAgent) {
    userAgents.remove(userAgent);
    _updateUserAgents();
  }

  /// Test whether a user agent is declared.
  ///
  /// The [userAgent] to look for.
  /// @Returns true if it is declared on this client, false otherwise.
  bool hasUserAgent(LibraryVersion userAgent) => userAgents.contains(userAgent);

  void _updateUserAgents() {
    final StringBuffer s = StringBuffer();
    for (LibraryVersion userAgent in userAgents) {
      if (s.isNotEmpty) {
        s.write('; ');
      }
      s..write(userAgent.name)..write(' (')..write(userAgent.version)..write(')');
    }
    userAgentRaw = s.toString();
  }

  List<String> get _readHostsThatAreUp => _hostsThatAreUp(_readHosts);

  List<String> get _writeHostsThatAreUp => _hostsThatAreUp(_writeHosts);

  Future<List<int>> getRequestRaw({
    @required String url,
    @required bool search,
    @required RequestOptions requestOptions,
    Map<String, String> urlParameters,
  }) {
    return _requestRaw(
      method: Method.get,
      url: url,
      urlParameters: urlParameters,
      body: null,
      hosts: _readHostsThatAreUp,
      requestOptions: requestOptions,
    );
  }

  Future<Map<String, dynamic>> getRequest({
    @required String url,
    @required bool search,
    RequestOptions requestOptions,
    Map<String, String> urlParameters,
  }) {
    return _request(
      method: Method.get,
      url: url,
      urlParameters: urlParameters,
      body: null,
      hosts: _readHostsThatAreUp,
      requestOptions: requestOptions,
    );
  }

  Future<Map<String, dynamic>> deleteRequest({
    @required String url,
    Map<String, String> urlParameters,
    RequestOptions requestOptions,
  }) {
    return _request(
      method: Method.delete,
      url: url,
      urlParameters: urlParameters,
      hosts: _writeHostsThatAreUp,
      requestOptions: requestOptions,
    );
  }

  Future<Map<String, dynamic>> postRequest({
    @required String url,
    @required Map<String, dynamic> body,
    @required bool readOperation,
    Map<String, String> urlParameters,
    RequestOptions requestOptions,
  }) {
    return _request(
      method: Method.post,
      url: url,
      urlParameters: urlParameters,
      body: body,
      hosts: readOperation ? _readHostsThatAreUp : _writeHostsThatAreUp,
      requestOptions: requestOptions,
    );
  }

  Future<List<int>> postRequestRaw({
    @required String url,
    @required Map<String, dynamic> body,
    @required bool readOperation,
    @required RequestOptions requestOptions,
    Map<String, String> urlParameters,
  }) {
    return _requestRaw(
      method: Method.post,
      url: url,
      urlParameters: urlParameters,
      body: body,
      hosts: readOperation ? _readHostsThatAreUp : _writeHostsThatAreUp,
      requestOptions: requestOptions,
    );
  }

  Future<Map<String, dynamic>> putRequest({
    @required String url,
    @required Map<String, dynamic> body,
    @required RequestOptions requestOptions,
    Map<String, String> urlParameters,
  }) {
    return _request(
      method: Method.put,
      url: url,
      urlParameters: urlParameters,
      body: body,
      hosts: _writeHostsThatAreUp,
      requestOptions: requestOptions,
    );
  }

  static Map<String, dynamic> getMap(dynamic input) {
    if (input is String) {
      // ignore: always_specify_types
      final Map result = jsonDecode(input);
      return Map<String, dynamic>.from(result);
    } else if (input is List<int>) {
      // ignore: always_specify_types
      final Map result = jsonDecode(utf8.decode(input));
      return Map<String, dynamic>.from(result);
    } else {
      throw StateError('Only String and List<int> are supported, but got $input');
    }
  }

  Future<Map<String, dynamic>> _request({
    @required Method method,
    @required String url,
    @required List<String> hosts,
    Map<String, dynamic> body,
    Map<String, String> urlParameters,
    RequestOptions requestOptions,
  }) async {
    try {
      final List<int> raw = await _requestRaw(
        method: method,
        url: url,
        urlParameters: urlParameters,
        body: body,
        hosts: hosts,
        requestOptions: requestOptions,
      );
      return getMap(raw);
    } on AlgoliaException catch (_) {
      rethrow;
    } catch (e) {
      throw AlgoliaException('$e', e);
    }
  }

  Future<List<int>> _requestRaw({
    @required Method method,
    @required String url,
    @required Map<String, String> urlParameters,
    @required Map<String, dynamic> body,
    @required List<String> hosts,
    RequestOptions requestOptions,
  }) async {
    String requestMethod;
    final List<dynamic> errors = <dynamic>[];
    // for each host
    for (String host in hosts) {
      print('host: $host');

      switch (method) {
        case Method.delete:
          requestMethod = 'DELETE';
          break;
        case Method.get:
          requestMethod = 'GET';
          break;
        case Method.post:
          requestMethod = 'POST';
          break;
        case Method.put:
          requestMethod = 'PUT';
          break;
        default:
          throw ArgumentError('Method $method is not supported');
      }

      Request request;
      StreamedResponse response;
      try {
        // Compute final URL parameters.
        final Map<String, String> parameters = <String, String>{};
        if (urlParameters != null) {
          parameters.addAll(urlParameters);
        }
        if (requestOptions != null) {
          parameters.addAll(requestOptions.urlParameters);
        }

        // Build URL.
        String urlString = 'https://$host$url';
        if (parameters.isNotEmpty) {
          urlString += '?${AbstractQuery.buildParams(parameters)}';
        }
        final Uri uri = Uri.parse(urlString);
        print('$method=>$uri');

        request = Request(requestMethod, uri);
        request.headers['X-Algolia-Application-Id'] = applicationID;

        // If API key is too big, send it in the request's body (if applicable).
        if (apiKey != null && apiKey.length > _maxApiKeyLength && body != null) {
          body['apiKey'] = apiKey;
        } else {
          request.headers['X-Algolia-API-Key'] = apiKey;
        }

        // Client-level headers
        for (MapEntry<String, String> entry in _headers.entries) {
          request.headers[entry.key] = entry.value;
        }

        // Request-level headers
        if (requestOptions != null) {
          for (MapEntry<String, String> entry in requestOptions.headers.entries) {
            request.headers[entry.key] = entry.value;
          }
        }

        // set user agent
        request.headers['User-Agent'] = userAgentRaw;

        // write JSON entity
        if (body != null) {
          if (!(requestMethod == 'PUT' || requestMethod == 'POST')) {
            throw ArgumentError('Method $method cannot enclose entity');
          }

          final String data = jsonEncode(body);
          request
            ..headers['content-type'] = 'application/json; charset=UTF-8'
            ..body = data;

          response = await request.send();
        } else {
          response = await request.send();
        }

        // read response
        final int code = response.statusCode;
        final bool codeIsError = code ~/ 100 != 2;
        hostStatuses[host] = _HostStatus(isUp: true);

        final List<int> rawResponse = <int>[];
        final Completer<void> completer = Completer<void>();
        response.stream.listen(
          rawResponse.addAll,
          onDone: completer.complete,
          onError: completer.completeError,
        );
        await completer.future;

        // handle http errors
        if (codeIsError) {
          if (code ~/ 100 == 4) {
            final String message = getMap(rawResponse)['message'];
            throw AlgoliaException(message, null, code);
          } else {
            errors.add(AlgoliaException(utf8.decode(rawResponse), null, code));
            continue;
          }
        }

        return rawResponse;
      } on SocketException catch (e) {
        hostStatuses[host] = _HostStatus(isUp: false);
        errors.add(e);
      }
    }

    final String errorMessage = 'All hosts failed: $errors';
    // When several errors occurred, use the last one as the cause for the
    // returned exception.
    throw AlgoliaException(errorMessage, errors.last);
  }

  /// Get the hosts that are not considered down in a given list.
  ///
  /// A list of [hosts] whose [_HostStatus] will be checked.
  /// Returns the hosts considered up, or all hosts if none is known to be
  /// reachable.

  List<String> _hostsThatAreUp(List<String> hosts) {
    final List<String> upHosts = <String>[];
    for (String host in hosts) {
      if (isUpOrCouldBeRetried(host)) {
        upHosts.add(host);
      }
    }
    return upHosts.isEmpty ? hosts : upHosts;
  }

  bool isUpOrCouldBeRetried(String host) {
    final _HostStatus status = hostStatuses[host];
    return status == null || status.isUp || DateTime.now().difference(status.lastTryTimestamp) >= hostDownDelay;
  }
}

/// A version of a software library.
/// Used to construct the <code>User-Agent</code> header.
class LibraryVersion {
  const LibraryVersion(this.name, this.version);

  final String name;
  final String version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryVersion && runtimeType == other.runtimeType && name == other.name && version == other.version;

  @override
  int get hashCode => name.hashCode ^ version.hashCode;
}

class _HostStatus {
  _HostStatus({this.isUp}) : lastTryTimestamp = DateTime.now();

  bool isUp = true;
  DateTime lastTryTimestamp;
}
