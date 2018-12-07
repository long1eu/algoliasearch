// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'package:algoliasearch/src/abstract_client.dart';
import 'package:algoliasearch/src/index.dart';
import 'package:algoliasearch/src/index_query.dart';
import 'package:algoliasearch/src/request_options.dart';
import 'package:meta/meta.dart';

/// Entry point to the Dart API.
/// You must instantiate a <code>Client</code> object with your application ID
/// and API key to start using Algolia Search API.
///
/// <p>
/// WARNING: For performance reasons, arguments to asynchronous methods are not
/// cloned. Therefore, you should not modify mutable arguments after they have
/// been passed (unless explicitly noted).
/// </p>
class Client extends AbstractClient {
  /// Create a new Algolia Search client targeting the default hosts.
  ///
  /// <p>
  /// NOTE: This is the recommended way to initialize a client is most use
  /// cases.
  ///
  /// The [applicationID] (available in your Algolia Dashboard). [apiKey] A
  /// valid API key for the service.
  factory Client(String applicationID, String apiKey) {
    return Client.forHosts(applicationID, apiKey, null);
  }

  /// Create a new Algolia Search client with explicit hosts to target.
  ///
  /// <p>
  /// NOTE: In most use cases, you should the default hosts. See [Client].
  ///
  /// The [applicationID] (available in your Algolia Dashboard). [apiKey] A
  /// valid API key for the service. An explicit list of hosts to target, or
  /// null to use the default hosts.
  Client.forHosts(String applicationID, String apiKey, List<String> hosts) : super(applicationID, apiKey, hosts, hosts) {
    if (hosts == null) {
      // Initialize hosts to their default values.
      //
      // NOTE: The host list comes in two parts:
      //
      // 1. The fault-tolerant, load-balanced DNS host.
      // 2. The non-fault-tolerant hosts. Those hosts must be randomized to
      //    ensure proper load balancing in case of the first host's failure.
      final List<String> fallbackHosts = <String>[
        '$applicationID-1.algolianet.com',
        '$applicationID-2.algolianet.com',
        '$applicationID-3.algolianet.com',
      ]..shuffle();

      readHosts = <String>[]
        ..add('$applicationID-dsn.algolia.net')
        ..addAll(fallbackHosts);

      writeHosts = <String>[]
        ..add('$applicationID.algolia.net')
        ..addAll(fallbackHosts);
    }
  }

  /// Cache of already created indices.
  Map<String, Index> indices = <String, Index>{};

  /// Obtain a proxy to an Algolia index (no server call required by this
  /// method).
  ///
  /// [name] is the name of the index.
  /// Returns a proxy to the specified index.
  Index getIndex(String name) {
    Index index;
    final Index existingIndex = indices[name];
    if (existingIndex != null) {
      index = existingIndex;
    }
    if (index == null) {
      index = Index(this, name);
      indices[name] = index;
    }
    return index;
  }

  /// List all existing indexes
  ///
  /// Returns a JSON Object in the form:
  /// ```json
  /// {
  ///   "items": [
  ///     {
  ///       "name": "contacts",
  ///       "createdAt": "2013-01-18T15:33:13.556Z"
  ///     },
  ///     {
  ///       "name": "notes",
  ///       "createdAt": "2013-01-18T15:33:13.556Z"
  ///     }
  ///   ]
  /// }
  /// ```
  Future<Map<String, dynamic>> listIndexes({RequestOptions requestOptions}) {
    return getRequest(
      url: '/1/indexes/',
      search: false,
      requestOptions: requestOptions,
    );
  }

  /// Delete an index
  ///
  /// @param requestOptions Request-specific options.
  /// @param name      the name of index to delete
  /// Return an object containing a "deletedAt" attribute
  Future<Map<String, dynamic>> deleteIndex({
    @required String name,
    RequestOptions requestOptions,
  }) {
    return deleteRequest(
      url: '/1/indexes/${Uri.encodeComponent(name)}',
      requestOptions: requestOptions,
    );
  }

  /// Move an existing index.
  ///
  /// [srcIndexName] the name of index to copy.
  /// [dstIndexName] the new index name that will contains a copy of
  /// [srcIndexName] (destination will be overriten if it already exist).
  /// [requestOptions] Request-specific options.
  Future<Map<String, dynamic>> moveIndex({
    @required String srcIndexName,
    @required String dstIndexName,
    RequestOptions requestOptions,
  }) {
    return postRequest(
      url: '/1/indexes/${Uri.encodeComponent(srcIndexName)}/operation',
      readOperation: false,
      requestOptions: requestOptions,
      body: <String, dynamic>{'operation': 'move', 'destination': dstIndexName},
    );
  }

  /// Copy an existing index.
  ///
  /// [srcIndexName] the name of index to copy.
  /// [dstIndexName] the new index name that will contains a copy of
  /// [srcIndexName] (destination will be overriten if it already exist).
  /// [requestOptions] Request-specific options.
  Future<Map<String, dynamic>> copyIndex({
    @required String srcIndexName,
    @required String dstIndexName,
    RequestOptions requestOptions,
  }) {
    return postRequest(
      url: '/1/indexes/${Uri.encodeComponent(srcIndexName)}/operation',
      urlParameters: null,
      body: <String, dynamic>{'operation': 'copy', 'destination': dstIndexName},
      readOperation: false,
      requestOptions: requestOptions,
    );
  }

  Future<Map<String, dynamic>> multipleQueries({
    @required List<IndexQuery> queries,
    String strategy,
    RequestOptions requestOptions,
  }) {
    final List<Map<String, dynamic>> requests = <Map<String, dynamic>>[];

    for (IndexQuery indexQuery in queries) {
      requests.add(<String, dynamic>{
        'indexName': indexQuery.indexName,
        'params': indexQuery.query.build(),
      });
    }

    final Map<String, dynamic> body = <String, dynamic>{'requests': requests};
    if (strategy != null) {
      body['strategy'] = strategy;
    }

    return postRequest(
      url: '/1/indexes/*/queries',
      body: body,
      readOperation: true,
      requestOptions: requestOptions,
    );
  }

  Future<Map<String, dynamic>> batch({
    @required List<Map<String, dynamic>> operations,
    RequestOptions requestOptions,
  }) {
    return postRequest(
      url: '/1/indexes/*/batch',
      body: <String, dynamic>{'requests': operations},
      readOperation: false,
      requestOptions: requestOptions,
    );
  }
}

/// Strategy when running multiple queries.

class MultipleQueriesStrategy {
  const MultipleQueriesStrategy._(this._i);

  final int _i;

  /// Execute the sequence of queries until the end.
  static const MultipleQueriesStrategy none = MultipleQueriesStrategy._(0);

  /// Execute the sequence of queries until the number of hits is reached by the
  /// sum of hits.
  static const MultipleQueriesStrategy stopIfEnoughMatches = MultipleQueriesStrategy._(0);

  static const List<MultipleQueriesStrategy> values = <MultipleQueriesStrategy>[
    none,
    stopIfEnoughMatches,
  ];

  static const List<String> _stringValues = <String>[
    'none',
    'stopIfEnoughMatches',
  ];

  @override
  String toString() => _stringValues[_i];
}
