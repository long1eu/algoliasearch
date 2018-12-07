// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'package:algoliasearch/src/abstract_query.dart';

import 'places_client.dart';

/// Search parameters for Algolia Places [PlacesClient.search]
class PlacesQuery extends AbstractQuery {
  PlacesQuery();

  /// Construct a query with the specified full text [query].
  PlacesQuery.fromString(String query) {
    this.query = query;
  }

  /// Clone an existing query.
  PlacesQuery.copy(PlacesQuery other) : super(other: other);

  /// Parse a query object from a URL [queryParameters] string.
  factory PlacesQuery.parse(String queryParameters) => PlacesQuery()..parseFrom(queryParameters);

  static const String _keyQuery = 'query';
  static const String _keyAroundLatLng = 'aroundLatLng';
  static const String _keyAroundLatLngViaIP = 'aroundLatLngViaIP';
  static const String _keyAroundRadius = 'aroundRadius';
  static const String _keyHighlightPostTag = 'highlightPostTag';
  static const String _keyHighlightPreTag = 'highlightPreTag';
  static const String _keyHitsPerPage = 'hitsPerPage';
  static const String _keyType = 'type';
  static const String _keyLanguage = 'language';
  static const String _keyCountries = 'countries';

  static const int kRadiusAll = 2 ^ 53;

  /// Set the full text query.
  set query(String query) => this[_keyQuery] = query;

  String get query => this[_keyQuery];

  /// Force to *first* search around a specific latitude/longitude.
  ///
  /// The default is to search around the location of the user determined via
  /// his IP address (geoip).
  ///
  /// The [location] to start the search at, or `null` to use the default.
  set aroundLatLng(LatLng location) {
    if (location == null) {
      this[_keyAroundLatLng] = null;
    } else {
      this[_keyAroundLatLng] = location.toString();
    }
  }

  LatLng get aroundLatLng => LatLng.parse(this[_keyAroundLatLng]);

  /// Search *first* around the geolocation of the user found via his IP
  /// address.
  ///
  /// Defaults to true.
  ///
  /// [enabled] whether to use IP address to determine geolocation, or null to
  /// use the default.
  set aroundLatLngViaIP(bool enabled) => this[_keyAroundLatLngViaIP] = enabled;

  bool get aroundLatLngViaIP => AbstractQuery.parseBool(this[_keyAroundLatLngViaIP]);

  /// Change the radius for around latitude/longitude queries.
  ///
  /// The [radius] to set, or [kRadiusAll] to disable stopping at a specific
  /// radius, or null to use the default.
  set aroundRadius(int radius) => radius == PlacesQuery.kRadiusAll ? this[_keyAroundRadius] = 'all' : this[_keyAroundRadius] = radius;

  /// Get the current radius for around latitude/longitude queries.
  ///
  /// Return [kRadiusAll] if set to 'all'.
  int get aroundRadius {
    final String value = this[_keyAroundRadius];
    return value != null && value == 'all' ? PlacesQuery.kRadiusAll : int.tryParse(value ?? '');
  }

  set highlightPostTag(String tag) => this[_keyHighlightPostTag] = tag;

  String get highlightPostTag => this[_keyHighlightPostTag];

  set highlightPreTag(String tag) => this[_keyHighlightPreTag] = tag;

  String get highlightPreTag => this[_keyHighlightPreTag];

  /// Set how many results you want to retrieve per search.
  ///
  /// Defaults to 20.
  set hitsPerPage(int nbHitsPerPage) => this[_keyHitsPerPage] = nbHitsPerPage;

  int get hitsPerPage => int.tryParse(this[_keyHitsPerPage] ?? '');

  /// Set the type of place to search for.
  set type(PlacesQueryType type) => this[_keyType] = type.toString();

  PlacesQueryType get type {
    final String value = this[_keyType];
    print(value);
    if (value != null) {
      switch (value) {
        case 'city':
          return PlacesQueryType.city;
        case 'country':
          return PlacesQueryType.country;
        case 'address':
          return PlacesQueryType.address;
        case 'busStop':
          return PlacesQueryType.busStop;
        case 'trainStation':
          return PlacesQueryType.trainStation;
        case 'townhall':
          return PlacesQueryType.townhall;
        case 'airport':
          return PlacesQueryType.airport;
      }
    }
    return null;
  }

  /// Restrict the search results to a single language. You can pass two letters
  /// country codes (<a href="https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes">ISO 639-1</a>).
  ///
  /// The [language] used to return the results, or null to use all available
  /// languages.
  set language(String language) => this[_keyLanguage] = language;

  String get language => this[_keyLanguage];

  /// Restrict the search results to a specific list of countries. You can pass
  /// two letters country codes (<a href="https://en.wikipedia.org/wiki/ISO_3166-1#Officially_assigned_code_elements">ISO 3166-1</a>).
  /// <p>
  /// Defaults to search on the whole planet.
  ///
  /// The [countries] to restrict the search to, or null to search on the whole
  /// planet.
  set countries(List<String> countries) => this[_keyCountries] = AbstractQuery.buildJSONArray(countries);

  List<String> get countries => AbstractQuery.parseArray(this[_keyCountries]);
}

/// Types of places that can be searched for.
class PlacesQueryType {
  const PlacesQueryType._(this._i);

  final int _i;

  static const PlacesQueryType city = PlacesQueryType._(0);
  static const PlacesQueryType country = PlacesQueryType._(1);
  static const PlacesQueryType address = PlacesQueryType._(2);
  static const PlacesQueryType busStop = PlacesQueryType._(3);
  static const PlacesQueryType trainStation = PlacesQueryType._(4);
  static const PlacesQueryType townhall = PlacesQueryType._(5);
  static const PlacesQueryType airport = PlacesQueryType._(6);

  static const List<PlacesQueryType> values = <PlacesQueryType>[city, country, address, busStop, trainStation, townhall, airport];

  static const List<String> _stringValues = <String>['city', 'country', 'address', 'busStop', 'trainStation', 'townhall', 'airport'];

  @override
  String toString() => _stringValues[_i];
}
