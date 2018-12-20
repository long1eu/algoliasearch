// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'package:algoliasearch/src/abstract_client.dart';
import 'package:algoliasearch/src/places/places_query.dart';

import '../algolia_exception.dart';

/// Client for [Algolia Places](https://community.algolia.com/places/).
class PlacesClient extends AbstractClient {
  /// Create a Algolia Places client. If you do not provide the
  /// [applicationID](available in your Algolia Dashboard) and the a valid
  /// [apiKey] for the service the client you will obtain an unauthenticated
  /// client.
  ///
  /// NOTE: The rate limit for the unauthenticated API is significantly lower
  /// than for the authenticated API.
  PlacesClient([String applicationID, String apiKey]) : super(applicationID, apiKey, null, null) {
    _setDefaultHosts();
  }

  /// Set the default hosts for Algolia Places.
  void _setDefaultHosts() {
    final List<String> fallbackHosts = <String>[
      'places-1.algolianet.com',
      'places-2.algolianet.com',
      'places-3.algolianet.com',
    ]..shuffle();

    hosts = <String>['places-dsn.algolia.net']..addAll(fallbackHosts);
  }

  /// Search for places.
  Future<Map<String, dynamic>> search(PlacesQuery params) {
    final Map<String, dynamic> body = <String, dynamic>{
      'params': PlacesQuery.copy(params).build(),
    };

    return postRequest(
      url: '/1/places/query',
      urlParameters: null,
      body: body,
      readOperation: true,
      requestOptions: null,
    );
  }

  /// Get a place by its objectID.
  ///
  /// [objectID] the record's identifier. Returns the corresponding record.
  /// @throws [AlgoliaException] when the given objectID does not exist.
  Future<Map<String, dynamic>> getByObjectID(String objectID) {
    return getRequest(
      url: '/1/places/$objectID',
      urlParameters: null,
      search: false,
      requestOptions: null,
    );
  }
}
