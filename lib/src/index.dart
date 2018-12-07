// File created by
// Lung Razvan <int1eu>
// on 2018-12-05

import 'package:algoliasearch/src/abstract_client.dart';
import 'package:algoliasearch/src/abstract_query.dart';
import 'package:algoliasearch/src/algolia_exception.dart';
import 'package:algoliasearch/src/expiring_cache.dart';
import 'package:algoliasearch/src/helpers/disjunctive_faceting.dart';
import 'package:algoliasearch/src/index_query.dart';
import 'package:algoliasearch/src/query.dart';
import 'package:algoliasearch/src/request_options.dart';
import 'package:meta/meta.dart';

import 'client.dart';
import 'searchable.dart';

/// A proxy to an Algolia index.
///
/// <p>
/// You cannot construct this class directly. Please use
/// [Client.getIndex(String)] to obtain an instance.
/// </p>
///
/// <p>
/// WARNING: For performance reasons, arguments to asynchronous methods are not
/// cloned. Therefore, you should not modify mutable arguments after they have
/// been passed (unless explicitly noted).
/// </p>
class Index extends Searchable {
  Index(this._client, this.rawIndexName)
      : encodedIndexName = Uri.encodeComponent(rawIndexName);

  /// This index's name, <b>not URL-encoded</b>.
  final String rawIndexName;

  /// This index's name, URL-encoded. Cached for optimization.
  final String encodedIndexName;

  /// The client to which this index beints.
  Client _client;

  static const int _keyDefaultSettingsVersion = 2;
  static const Duration _maxTimeToWait = Duration(seconds: 5);

  ExpiringCache<String, List<int>> _searchCache;
  bool _isCacheEnabled = false;

  Client get client => _client;

  @visibleForTesting
  set client(Client client) => _client = client ?? _client;

  /// Perform a search with disjunctive facets, generating as many queries as
  /// number of disjunctive facets (helper).
  @override
  Future<Map<String, dynamic>> searchDisjunctiveFacetingAsync(
      {@required Query query,
      @required List<String> disjunctiveFacets,
      @required Map<String, List<String>> refinements,
      RequestOptions requestOptions}) {
    assert(query != null);
    assert(disjunctiveFacets != null);

    return DisjunctiveFaceting(
        multipleQueriesAsync: (List<Query> queries) => multipleQueries(
            queries: queries,
            requestOptions: requestOptions)).searchDisjunctiveFacetingAsync(
        query: query,
        disjunctiveFacets: disjunctiveFacets,
        refinements: refinements);
  }

  /// Searches for some text in a facet values, optionally restricting the
  /// returned values to those contained in objects matching other (regular)
  /// search criteria.
  ///
  /// [facetName] - The name of the facet to search. It must have been declared
  ///               in the index's `attributesForFaceting` setting with the
  ///               `searchable()` modifier.
  /// [facetText] - The text to search for in the facet's values.
  /// [query]     - An optional query to take extra search parameters into
  ///               account. There parameters apply to index objects like in a
  ///               regular search query. Only facet values contained in the
  ///               matched objects will be returned
  Future<Map<String, dynamic>> searchForFacetValues(
      {@required String facetName,
      @required String facetText,
      Query query,
      RequestOptions requestOptions}) async {
    assert(facetName != null && facetName.isNotEmpty);
    assert(facetText != null && facetText.isNotEmpty);

    final String path =
        '/1/indexes/$encodedIndexName/facets/${Uri.encodeComponent(facetName)}/query';
    final Query params = query != null ? Query.copy(query) : Query();
    params['facetQuery'] = facetText;

    return _client.postRequest(
      url: path,
      body: <String, dynamic>{'params': params.build()},
      readOperation: true,
      requestOptions: requestOptions,
    );
  }

  /// Enable search cache with custom parameters
  ///
  /// [timeoutInSeconds]duration during which an request is kept in cache
  /// [maxRequests]     maximum amount of requests to keep before removing the least recently used
  void enableSearchCache({
    Duration timeoutInSeconds = ExpiringCache.defaultExpirationTimeout,
    int maxRequests = ExpiringCache.defaultMaxSize,
  }) {
    _isCacheEnabled = true;
    _searchCache =
        ExpiringCache<String, List<int>>(timeoutInSeconds, maxRequests);
  }

  /// Disable and reset cache
  void disableSearchCache() {
    _isCacheEnabled = false;
    _searchCache?.clear();
  }

  /// Remove all entries from cache
  void clearSearchCache() => _searchCache?.clear();

  /// Adds an object in this index.
  ///
  /// [object]            the object to add.
  /// [objectId] an objectID you want to attribute to this object (if the
  /// attribute already exist the old object will be overwrite)
  /// [requestOptions] Request-specific options.
  Future<Map<String, dynamic>> addObject(Map<String, dynamic> object,
      {String objectId, RequestOptions requestOptions}) {
    if (objectId == null) {
      return _client.postRequest(
        url: '/1/indexes/$encodedIndexName',
        body: object,
        readOperation: false,
        requestOptions: requestOptions,
      );
    } else {
      return _client.putRequest(
        url: '/1/indexes/$encodedIndexName/${Uri.encodeComponent(objectId)}',
        body: object,
        requestOptions: requestOptions,
      );
    }
  }

  /// Custom batch.
  Future<Map<String, dynamic>> batch(List<Map<String, dynamic>> actions,
      {RequestOptions requestOptions}) {
    return _client.postRequest(
      url: '/1/indexes/$encodedIndexName/batch',
      urlParameters: null,
      body: <String, dynamic>{'requests': actions},
      readOperation: false,
      requestOptions: requestOptions,
    );
  }

  /// Adds several objects.
  ///
  /// [objects] -> contains an array of objects to add.
  Future<Map<String, dynamic>> addObjects(List<Map<String, dynamic>> objects,
      {RequestOptions requestOptions}) {
    final List<Map<String, dynamic>> actions = <Map<String, dynamic>>[];
    for (int n = 0; n < objects.length; n++) {
      actions.add(<String, dynamic>{
        'action': 'addObject',
        'body': objects[n],
      });
    }
    return batch(actions, requestOptions: requestOptions);
  }

  /// Gets an object from this index.
  ///
  /// [attributesToRetrieve] contains the list of attributes to retrieve.
  Future<Map<String, dynamic>> getObject(String objectId,
      {List<String> attributesToRetrieve, RequestOptions requestOptions}) {
    final String path =
        '/1/indexes/$encodedIndexName/${Uri.encodeComponent(objectId)}';

    Map<String, String> urlParameters;
    if (attributesToRetrieve != null) {
      urlParameters = <String, String>{
        'attributesToRetrieve':
            AbstractQuery.buildCommaArray(attributesToRetrieve),
      };
    }
    return _client.getRequest(
      url: path,
      urlParameters: urlParameters,
      search: false,
      requestOptions: requestOptions,
    );
  }

  /// Gets several objects from this index.
  ///
  /// [objectIDs]           the array of unique identifier of objects to retrieve
  /// [attributesToRetrieve]contains the list of attributes to retrieve.
  Future<Map<String, dynamic>> getObjects(List<String> objectIDs,
      {List<String> attributesToRetrieve, RequestOptions requestOptions}) {
    final List<Map<String, dynamic>> requests = <Map<String, dynamic>>[];
    for (String id in objectIDs) {
      final Map<String, dynamic> request = <String, dynamic>{
        'indexName': rawIndexName,
        'objectID': id
      };

      if (attributesToRetrieve != null) {
        request['attributesToRetrieve'] = attributesToRetrieve;
      }

      requests.add(request);
    }

    return _client.postRequest(
      url: '/1/indexes/*/objects',
      body: <String, dynamic>{'requests': requests},
      readOperation: true,
      requestOptions: requestOptions,
    );
  }

  /// Update partially an object (only update attributes passed in argument).
  ///
  /// [partialObject] the object attributes to override
  Future<Map<String, dynamic>> partialUpdateObject({
    @required Map<String, dynamic> partialObject,
    @required String objectID,
    bool createIfNotExists,
    RequestOptions requestOptions,
  }) {
    final String path =
        '/1/indexes/$encodedIndexName/${Uri.encodeComponent(objectID)}/partial';
    final Map<String, String> urlParameters = <String, String>{};
    if (createIfNotExists != null) {
      urlParameters['createIfNotExists'] = createIfNotExists.toString();
    }
    return _client.postRequest(
      url: path,
      urlParameters: urlParameters,
      body: partialObject,
      readOperation: false,
      requestOptions: requestOptions,
    );
  }

  /// Partially Override the content of several objects.
  ///
  /// [objects] -> the array of objects to update (each object must contains
  /// an objectID attribute)
  Future<Map<String, dynamic>> partialUpdateObjects(
      {@required List<Map<String, dynamic>> objects,
      @required bool createIfNotExists,
      RequestOptions requestOptions}) {
    final String action = createIfNotExists
        ? 'partialUpdateObject'
        : 'partialUpdateObjectNoCreate';

    final List<Map<String, dynamic>> array = <Map<String, dynamic>>[];
    for (int n = 0; n < objects.length; n++) {
      final Map<String, dynamic> object = objects[n];
      final Map<String, dynamic> operation = <String, dynamic>{
        'action': action,
        'objectID': object['objectID'],
        'body': object,
      };

      array.add(operation);
    }
    return batch(array, requestOptions: requestOptions);
  }

  /// Override the content of object.
  Future<Map<String, dynamic>> saveObject(
      {@required Map<String, dynamic> object,
      @required String objectID,
      RequestOptions requestOptions}) {
    return _client.putRequest(
      url: '/1/indexes/$encodedIndexName/${Uri.encodeComponent(objectID)}',
      urlParameters: null,
      body: object,
      requestOptions: requestOptions,
    );
  }

  /// Override the content of several objects.
  ///
  /// [objects] -> contains an array of objects to update (each object must
  /// contains an objectID attribute)
  Future<Map<String, dynamic>> saveObjects(List<Map<String, dynamic>> objects,
      {RequestOptions requestOptions}) {
    final List<Map<String, dynamic>> array = <Map<String, dynamic>>[];
    for (int n = 0; n < objects.length; n++) {
      final Map<String, dynamic> obj = objects[n];

      array.add(<String, dynamic>{
        'action': 'updateObject',
        'objectID': obj['objectID'],
        'body': obj,
      });
    }
    return batch(array, requestOptions: requestOptions);
  }

  /// Deletes an object from the index.
  Future<Map<String, dynamic>> deleteObject(String objectID,
      {RequestOptions requestOptions}) {
    if (objectID.isEmpty) {
      throw AlgoliaException('Invalid objectID');
    }

    return _client.deleteRequest(
      url: '/1/indexes/$encodedIndexName/${Uri.encodeComponent(objectID)}',
      urlParameters: null,
      requestOptions: requestOptions,
    );
  }

  /// Deletes several objects.
  Future<Map<String, dynamic>> deleteObjects(List<String> objects,
      {RequestOptions requestOptions}) {
    final List<Map<String, dynamic>> actions = <Map<String, dynamic>>[];
    for (String id in objects) {
      actions.add(<String, dynamic>{
        'action': 'deleteObject',
        'body': <String, dynamic>{
          'objectID': id,
        }
      });
    }
    return batch(actions, requestOptions: requestOptions);
  }

  /// Deletes all records matching the query.
  Future<Map<String, dynamic>> deleteBy(Query query,
      {RequestOptions requestOptions}) async {
    return _client.postRequest(
      url: '/1/indexes/$encodedIndexName/deleteByQuery',
      body: <String, String>{'params': query.build()},
      urlParameters: query.parameters,
      readOperation: false,
      requestOptions: requestOptions,
    );
  }

  /// Searches inside the index.
  @override
  Future<Map<String, dynamic>> search(Query query,
      {RequestOptions requestOptions}) async {
    final Query q = query ?? Query();

    String cacheKey;
    List<int> rawResponse;
    if (_isCacheEnabled) {
      cacheKey = q.build();
      rawResponse = _searchCache[cacheKey];
    }

    if (rawResponse == null) {
      rawResponse = await searchRaw(q, requestOptions: requestOptions);
      if (_isCacheEnabled) {
        _searchCache[cacheKey] = rawResponse;
      }
    }
    return AbstractClient.getMap(rawResponse);
  }

  /// Searches inside the index.
  Future<List<int>> searchRaw(Query query, {RequestOptions requestOptions}) {
    final Query q = query ?? Query();

    final String paramsString = q.build();
    if (paramsString.isNotEmpty) {
      return _client.postRequestRaw(
        url: '/1/indexes/$encodedIndexName/query',
        body: <String, dynamic>{'params': paramsString},
        readOperation: true,
        requestOptions: requestOptions,
      );
    } else {
      return _client.getRequestRaw(
        url: '/1/indexes/$encodedIndexName',
        search: true,
        requestOptions: requestOptions,
      );
    }
  }

  /// Wait the action of a task on the server. All server task are asynchronous
  /// and you can check with this method that the task is published.
  Future<Map<String, dynamic>> waitTask(int taskID,
      [Duration timeToWait = _maxTimeToWait]) async {
    Duration waitTime = timeToWait;
    // ignore: literal_only_boolean_expressions
    while (true) {
      final Map<String, dynamic> obj = await _client.getRequest(
          url: '/1/indexes/$encodedIndexName/task/$taskID', search: false);

      if (obj['status'] == 'published') {
        return obj;
      }

      try {
        await Future<void>.delayed(
            timeToWait >= _maxTimeToWait ? _maxTimeToWait : waitTime);
      } catch (e) {
        continue;
      }

      final int newTimeout = waitTime.inMilliseconds * 2;

      waitTime = newTimeout <= 0 || newTimeout >= _maxTimeToWait.inMilliseconds
          ? _maxTimeToWait
          : Duration(milliseconds: newTimeout);
    }
  }

  /// Gets the settings of this index for a specific settings format.
  Future<Map<String, dynamic>> getSettings(
      {int formatVersion, RequestOptions requestOptions}) {
    final Map<String, String> urlParameters = <String, String>{
      'getVersion': (formatVersion ?? _keyDefaultSettingsVersion).toString()
    };
    return _client.getRequest(
      url: '/1/indexes/$encodedIndexName/settings',
      urlParameters: urlParameters,
      search: false,
      requestOptions: requestOptions,
    );
  }

  /// Set this index's settings (asynchronously).
  /// <p>
  /// Please refer to our <a href="https://www.algolia.com/doc/android#index-settings">API documentation</a> for the
  /// list of supported settings.
  Future<Map<String, dynamic>> setSettings(
      {@required Map<String, dynamic> settings,
      @required bool forwardToReplicas,
      RequestOptions requestOptions}) {
    return _client.putRequest(
      url: '/1/indexes/$encodedIndexName/settings',
      urlParameters: <String, String>{
        'forwardToReplicas': '$forwardToReplicas'
      },
      body: settings,
      requestOptions: requestOptions,
    );
  }

  /// Deletes the index content without removing settings and index specific API
  /// keys.
  Future<Map<String, dynamic>> clearIndex({RequestOptions requestOptions}) {
    return _client.postRequest(
      url: '/1/indexes/$encodedIndexName/clear',
      urlParameters: null,
      body: <String, dynamic>{},
      readOperation: false,
      requestOptions: requestOptions,
    );
  }

  /// Browse all index content (initial call).
  /// This method should be called once to initiate a browse. It will return the
  /// first page of results and a cursor, unless the end of the index has been
  /// reached. To retrieve subsequent pages, call [browseFrom] with that
  /// cursor.
  Future<Map<String, dynamic>> browse(Query query,
      {RequestOptions requestOptions}) {
    return _client.getRequest(
      url: '/1/indexes/$encodedIndexName/browse',
      urlParameters: query.parameters,
      search: true,
      requestOptions: requestOptions,
    );
  }

  /// Browse the index from a cursor. This method should be called after an
  /// initial call to [browse]. It returns a cursor, unless the end of the index
  /// has been reached.
  Future<Map<String, dynamic>> browseFrom(String cursor,
      {RequestOptions requestOptions}) {
    return _client.getRequest(
      url: '/1/indexes/$encodedIndexName/browse',
      urlParameters: <String, String>{'cursor': cursor},
      search: true,
      requestOptions: requestOptions,
    );
  }

  /// Run multiple queries on this index with one API call. A variant of
  /// [Client.multipleQueries] where all queries target this index.
  Future<Map<String, dynamic>> multipleQueries(
      {@required List<Query> queries,
      MultipleQueriesStrategy strategy,
      RequestOptions requestOptions}) {
    return _client.multipleQueries(
      queries: queries
          .map((Query it) => IndexQuery(index: this, query: Query.copy(it)))
          .toList(),
      strategy: strategy.toString(),
      requestOptions: requestOptions,
    );
  }

  @override
  String toString() => '$runtimeType{$rawIndexName}';
}
