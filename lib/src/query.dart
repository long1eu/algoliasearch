// File created by
// Lung Razvan <long1eu>
// on 2018-12-04

import 'dart:convert';

import 'package:algoliasearch/src/abstract_query.dart';
import 'package:algoliasearch/src/algolia_exception.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Describes all parameters of a search query.
class Query extends AbstractQuery {
  Query();

  /// Construct a query with the specified query text.
  ///
  /// [query] text.
  Query.value(String query) {
    this.query = query;
  }

  /// Clone an existing query.
  ///
  /// [other] the query to be cloned.
  Query.copy(Query other) : super(other: other);

  /// Parse a query object from a URL query parameter string.
  ///
  /// [queryParameters] URL query parameter string.
  factory Query.parse(String queryParameters) =>
      Query()..parseFrom(queryParameters);

  static const int kRadiusAll = 2 ^ 53;

  static const String _keyAdvancedSyntax = 'advancedSyntax';
  static const String _keyAllowTyposOnNumericTokens =
      'allowTyposOnNumericTokens';
  static const String _keyAnalytics = 'analytics';
  static const String _keyAnalyticsTags = 'analyticsTags';
  static const String _keyAroundLatLng = 'aroundLatLng';
  static const String _keyAroundLatLngViaIP = 'aroundLatLngViaIP';
  static const String _keyAroundPrecision = 'aroundPrecision';
  static const String _keyAroundRadius = 'aroundRadius';
  static const String _keyAttributesToHighlight = 'attributesToHighlight';
  static const String _keyAttributesToRetrieve = 'attributesToRetrieve';
  static const String _keyAttributesToRetrieveLegacy = 'attributes';
  static const String _keyAttributesToSnippet = 'attributesToSnippet';
  static const String _keyClickAnalytics = 'clickAnalytics';
  static const String _keyDisableExactOnAttributes = 'disableExactOnAttributes';
  static const String _keyDisableTypoToleranceOnAttributes =
      'disableTypoToleranceOnAttributes';
  static const String _keyDistinct = 'distinct';
  static const String _keyFacets = 'facets';
  static const String _keyFacetFilters = 'facetFilters';
  static const String _keyFacetingAfterDistinct = 'facetingAfterDistinct';
  static const String _keyFilters = 'filters';
  static const String _keyGetRankingInfo = 'getRankingInfo';
  static const String _keyHighlightPostTag = 'highlightPostTag';
  static const String _keyHighlightPreTag = 'highlightPreTag';
  static const String _keyHitsPerPage = 'hitsPerPage';
  static const String _keyIgnorePlurals = 'ignorePlurals';
  static const String _keyInsideBoundingBox = 'insideBoundingBox';
  static const String _keyInsidePolygon = 'insidePolygon';
  static const String _keyLength = 'length';
  static const String _keyMaxFacetHits = 'maxFacetHits';
  static const String _keyMaxValuesPerFacet = 'maxValuesPerFacet';
  static const String _keyMinimumAroundRadius = 'minimumAroundRadius';
  static const String _keyMinProximity = 'minProximity';
  static const String _keyMinWordSizeFor1Typo = 'minWordSizefor1Typo';
  static const String _keyMinWordSizeFor2Typos = 'minWordSizefor2Typos';
  static const String _keyOffset = 'offset';
  static const String _keyOptionalWords = 'optionalWords';
  static const String _keyOptionalFilters = 'optionalFilters';
  static const String _keyPage = 'page';
  static const String _keyPercentileComputation = 'percentileComputation';
  static const String _keyQuery = 'query';
  static const String _keyQueryType = 'queryType';
  static const String _keyRemoveStopWords = 'removeStopWords';
  static const String _keyRemoveWordsIfNoResults = 'removeWordsIfNoResults';
  static const String _keyReplaceSynonymsInHighlight =
      'replaceSynonymsInHighlight';
  static const String _keyRestrictHighlightAndSnippetArrays =
      'restrictHighlightAndSnippetArrays';
  static const String _keyRestrictSearchableAttributes =
      'restrictSearchableAttributes';
  static const String _keyRuleContexts = 'ruleContexts';
  static const String _keySnippetEllipsisText = 'snippetEllipsisText';
  static const String _keySortFacetValuesBy = 'sortFacetValuesBy';
  static const String _keySumOrFiltersScores = 'sumOrFiltersScores';
  static const String _keySynonyms = 'synonyms';
  static const String _keyTagFilters = 'tagFilters';
  static const String _keyTypoTolerance = 'typoTolerance';
  static const String _keyExactOnSingleWordQuery = 'exactOnSingleWordQuery';
  static const String _keyEnableRules = 'enableRules';
  static const String _keyAlternativesAsExact = 'alternativesAsExact';
  static const String _keyResponseFields = 'responseFields';

  /// Enable the advanced query syntax.
  ///
  /// - Phrase query: a phrase query defines a particular sequence of terms.
  /// A phrase query is build by Algolia's query parser for words surrounded by
  /// '. For example, 'search engine' will retrieve records having search next
  /// to engine only. Typo-tolerance is disabled on phrase queries.
  ///
  /// - Prohibit operator: The prohibit operator excludes records that contain
  /// the term after the - symbol. For example search -engine will retrieve
  /// records containing search but not engine.
  ///
  ///  Defaults to false.
  set advancedSyntax(bool enabled) => this[_keyAdvancedSyntax] = enabled;

  bool get advancedSyntax => AbstractQuery.parseBool(this[_keyAdvancedSyntax]);

  /// [enabled] If set to false, disable typo-tolerance on numeric tokens.
  ///
  /// Defaults to true.
  set allowTyposOnNumericTokens(bool enabled) =>
      this[_keyAllowTyposOnNumericTokens] = enabled;

  bool get allowTyposOnNumericTokens =>
      AbstractQuery.parseBool(this[_keyAllowTyposOnNumericTokens]);

  /// [enabled] If set to false, this query will not be taken into account in
  /// analytics feature.
  ///
  /// Defaults to true.
  set analytics(bool enabled) => this[_keyAnalytics] = enabled;

  bool get analytics => AbstractQuery.parseBool(this[_keyAnalytics]);

  /// The analytics [tags] identifying the query
  set analyticsTags(List<String> tags) =>
      this[_keyAnalyticsTags] = AbstractQuery.buildJSONArray(tags);

  List<String> get analyticsTags {
    return AbstractQuery.parseArray(this[_keyAnalyticsTags]);
  }

  /// Search for entries around a given latitude/longitude.
  set aroundLatLng(LatLng location) {
    if (location == null) {
      this[_keyAroundLatLng] = null;
    } else {
      this[_keyAroundLatLng] = location.toString();
    }
  }

  LatLng get aroundLatLng => LatLng.parse(this[_keyAroundLatLng]);

  /// Search for entries around the latitude/longitude of user (using IP
  /// geolocation)
  set aroundLatLngViaIP(bool enabled) => this[_keyAroundLatLngViaIP] = enabled;

  bool get aroundLatLngViaIP =>
      AbstractQuery.parseBool(this[_keyAroundLatLngViaIP]);

  /// Change the radius or around latitude/longitude query
  set aroundPrecision(int precision) => this[_keyAroundPrecision] = precision;

  int get aroundPrecision => AbstractQuery.parseInt(this[_keyAroundPrecision]);

  /// Change the radius for around latitude/longitude queries.
  ///
  /// [radius] the radius to set, or [Query.kRadiusAll] to disable stopping at
  /// a specific radius.
  set aroundRadius(int radius) =>
      this[_keyAroundRadius] = radius == Query.kRadiusAll ? 'all' : radius;

  /// Get the current radius for around latitude/longitude queries.
  ///
  /// Returns [Query.kRadiusAll] if set to 'all'.
  int get aroundRadius {
    final String value = this[_keyAroundRadius];
    return value != null && value == 'all'
        ? Query.kRadiusAll
        : AbstractQuery.parseInt(value);
  }

  /// Specify the list of attribute names to highlight. By default indexed
  /// attributes are highlighted.
  set attributesToHighlight(List<String> attributes) =>
      this[_keyAttributesToHighlight] =
          AbstractQuery.buildJSONArray(attributes);

  List<String> get attributesToHighlight =>
      AbstractQuery.parseArray(this[_keyAttributesToHighlight]);

  /// Specify the list of attribute names to retrieve. By default all
  /// attributes are retrieved.
  set attributesToRetrieve(List<String> attributes) =>
      this[_keyAttributesToRetrieve] = AbstractQuery.buildJSONArray(attributes);

  List<String> get attributesToRetrieve {
    List<String> result =
        AbstractQuery.parseArray(this[_keyAttributesToRetrieve]);
    return result ??=
        AbstractQuery.parseArray(this[_keyAttributesToRetrieveLegacy]);
  }

  /// Specify the list of attribute names to Snippet alongside the number of
  /// words to return (syntax is 'attributeName:nbWords'). By default no
  /// snippet is computed.
  set attributesToSnippet(List<String> attributes) =>
      this[_keyAttributesToSnippet] = AbstractQuery.buildJSONArray(attributes);

  List<String> get attributesToSnippet =>
      AbstractQuery.parseArray(this[_keyAttributesToSnippet]);

  /// [enabled] if set to true, the results will return queryID which is
  /// needed for sending click | conversion events.
  ///
  /// Defaults to false.
  set clickAnalytics(bool enabled) => this[_keyClickAnalytics] = enabled;

  bool get clickAnalytics {
    return AbstractQuery.parseBool(this[_keyClickAnalytics]);
  }

  /// List of attributes on which you want to disable computation of the exact
  /// ranking criterion (must be a subset of the searchableAttributes index
  /// setting).
  set disableExactOnAttributes(List<String> attributes) =>
      this[_keyDisableExactOnAttributes] =
          AbstractQuery.buildJSONArray(attributes);

  List<String> get disableExactOnAttributes =>
      AbstractQuery.parseArray(this[_keyDisableExactOnAttributes]);

  /// List of attributes on which you want to disable typo tolerance (must be a
  /// subset of the searchableAttributes index setting).
  set disableTypoToleranceOnAttributes(List<String> attributes) {
    this[_keyDisableTypoToleranceOnAttributes] =
        AbstractQuery.buildJSONArray(attributes);
  }

  List<String> get disableTypoToleranceOnAttributes =>
      AbstractQuery.parseArray(this[_keyDisableTypoToleranceOnAttributes]);

  /// This feature is similar to the distinct just before but instead of keeping
  /// the best value per value of attributeForDistinct, it allows to keep N
  /// values.
  ///
  /// [nbHitsToKeep] specify the maximum number of hits to keep for each
  /// distinct value
  set distinct(int nbHitsToKeep) => this[_keyDistinct] = nbHitsToKeep;

  int get distinct => AbstractQuery.parseInt(this[_keyDistinct]);

  /// List of object attributes that you want to use for faceting.
  ///
  /// Only attributes that have been added in **attributesForFaceting** index
  /// setting can be used in this parameter. You can also use `*` to perform
  /// faceting on all attributes specified in **attributesForFaceting**.
  set facets(List<String> facets) =>
      this[_keyFacets] = AbstractQuery.buildJSONArray(facets);

  List<String> get facets => AbstractQuery.parseArray(this[_keyFacets]);

  set facetFilters(List<dynamic> filters) =>
      this[_keyFacetFilters] = jsonEncode(filters);

  List<dynamic> get facetFilters {
    try {
      final String value = this[_keyFacetFilters];
      if (value != null) {
        // ignore: always_specify_types
        final List result = jsonDecode(value);
        return result;
      }
    } catch (e) {
      // Will return null
    }
    return null;
  }

  bool get facetingAfterDistinct =>
      AbstractQuery.parseBool(this[_keyFacetingAfterDistinct]);

  /// Force faceting to be applied after de-duplication. Please check
  /// <a href='https://www.algolia.com/doc/rest-api/search/#facetingafterdistinct'>documentation</a>
  /// for consequences and limitations
  ///
  /// [enabled] if true, facets will be computed after de-duplication is
  /// applied.
  /// <a href='https://www.algolia.com/doc/api-client/android/parameters/#facetingafterdistinct'>facetingAfterDistinct's documentation</a>
  set facetingAfterDistinct(bool enabled) =>
      this[_keyFacetingAfterDistinct] = enabled;

  /// Filter the query with numeric, facet or/and tag filters.
  /// <p>
  /// The syntax is a SQL like syntax, you can use the OR and AND keywords. The
  /// syntax for the underlying numeric, facet and tag filters is the same than
  /// in the other filters:
  /// ```
  ///   available=1 AND
  ///     (category:Book OR NOT category:Ebook) AND
  ///     _tags: date: 1441745506 TO 1441755506 AND inStock > 0 AND
  ///     author:'John Doe'
  /// ```
  ///
  /// [filters] a string following the given syntax.
  /// Returns the [Query] for chaining.
  set filters(String filters) => this[_keyFilters] = filters;

  /// Get the numeric, facet or/and tag filters for this Query.
  ///
  /// @return a String with this query's filters.
  String get filters => this[_keyFilters];

  /// If set, the result hits will contain ranking information in rankingInfo
  /// attribute.
  set getRankingInfo(bool enabled) => this[_keyGetRankingInfo] = enabled;

  bool get getRankingInfo => AbstractQuery.parseBool(this[_keyGetRankingInfo]);

  set highlightPostTag(String tag) => this[_keyHighlightPostTag] = tag;

  String get highlightPostTag => this[_keyHighlightPostTag];

  set highlightPreTag(String tag) => this[_keyHighlightPreTag] = tag;

  String get highlightPreTag => this[_keyHighlightPreTag];

  /// Set the number of hits per page.
  ///
  /// Defaults to 10.
  set hitsPerPage(int nbHitsPerPage) => this[_keyHitsPerPage] = nbHitsPerPage;

  int get hitsPerPage => AbstractQuery.parseInt(this[_keyHitsPerPage]);

  set ignorePlurals(IgnorePlurals ignorePlurals) {
    if (ignorePlurals == null) {
      this[_keyIgnorePlurals] = null;
      return;
    } else {
      this[_keyIgnorePlurals] = ignorePlurals;
    }
  }

  IgnorePlurals get ignorePlurals =>
      IgnorePlurals.parse(this[_keyIgnorePlurals]);

  /// Search for entries inside one area or the union of several areas defined
  /// by the two extreme points of a rectangle.
  set insideBoundingBox(List<GeoRect> boxes) {
    if (boxes == null) {
      this[_keyInsideBoundingBox] = null;
    } else {
      final StringBuffer sb = StringBuffer();
      for (GeoRect box in boxes) {
        if (sb.isNotEmpty) {
          sb.write(',');
        }
        sb
          ..write(box.p1.lat)
          ..write(',')
          ..write(box.p1.lng)
          ..write(',')
          ..write(box.p2.lat)
          ..write(',')
          ..write(box.p2.lng);
      }
      this[_keyInsideBoundingBox] = sb.toString();
    }
  }

  List<GeoRect> get insideBoundingBox {
    try {
      final String value = this[_keyInsideBoundingBox];
      if (value != null) {
        final List<String> fields = value.split(',');
        if (fields.length % 4 == 0) {
          final List<GeoRect> result = <GeoRect>[]..length = fields.length ~/ 4;
          for (int i = 0; i < result.length; ++i) {
            result[i] = GeoRect(
              LatLng(
                  double.parse(fields[4 * i]), double.parse(fields[4 * i + 1])),
              LatLng(double.parse(fields[4 * i + 2]),
                  double.parse(fields[4 * i + 3])),
            );
          }
          return result;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Search for entries inside a given area defined by either points of a
  /// polygon or several polygons.
  set insidePolygon(dynamic values /*List<LatLng>|List<Polygon>*/) {
    if (values is List<LatLng>) {
      final List<LatLng> points = values;
      this[_keyInsidePolygon] =
          points == null ? null : Polygon(points).toString();
    } else if (values is List<Polygon>) {
      final List<Polygon> polygons = values;

      String insidePolygon;
      if (polygons == null) {
        insidePolygon = null;
      } else if (polygons.length == 1) {
        insidePolygon = polygons[0].toString();
      } else {
        for (Polygon polygon in polygons) {
          final String polygonStr = '[$polygon]';
          if (insidePolygon == null) {
            insidePolygon = '[';
          } else {
            insidePolygon += ',';
          }
          insidePolygon += polygonStr;
        }
        insidePolygon += ']';
      }

      this[_keyInsidePolygon] = insidePolygon;
    } else {
      throw ArgumentError(
          'value must be eather a List<LatLng> or a List<Polygon>, '
          'but it was ${values.runtimeType}');
    }
  }

  List<Polygon> get insidePolygon {
    final String value = this[_keyInsidePolygon];

    if (value == null) {
      return null;
    } else if (value.startsWith('[')) {
      final List<String> values = value.substring(1, value.length).split('],[');
      final List<Polygon> polygons = <Polygon>[]..length = values.length;
      for (int i = 0; i < values.length; i++) {
        polygons[i] =
            Polygon.parse(values[i].replaceAll('[', '').replaceAll(']', ''));
      }
      return polygons;
    } else {
      final Polygon polygon = Polygon.parse(value);
      return <Polygon>[polygon];
    }
  }

  /// Maximum number of hits to return.
  /// <p>
  /// In most cases, [page] page/[hitsPerPage] hitsPerPage is the recommended
  /// method for pagination.
  ///
  /// [n] the number of hits to return. (Maximum 1000)
  set length(int n) => this[_keyLength] = n;

  int get length => AbstractQuery.parseInt(this[_keyLength]);

  /// Limit the number of facet values returned for each facet.
  set maxFacetHits(int n) => this[_keyMaxFacetHits] = n;

  int get maxFacetHits => AbstractQuery.parseInt(this[_keyMaxFacetHits]);

  /// Limit the number of facet values returned for each facet.
  set maxValuesPerFacet(int n) => this[_keyMaxValuesPerFacet] = n;

  int get maxValuesPerFacet =>
      AbstractQuery.parseInt(this[_keyMaxValuesPerFacet]);

  /// Specify the minimum number of characters in a query word to accept one
  /// typo in this word.
  ///
  /// Defaults to 3.
  set minimumAroundRadius(int minimumAroundRadius) =>
      this[_keyMinimumAroundRadius] = minimumAroundRadius;

  int get minimumAroundRadius =>
      AbstractQuery.parseInt(this[_keyMinimumAroundRadius]);

  /// Specify the minimum number of characters in a query word to accept one
  /// typo in this word.
  ///
  /// Defaults to 3.
  set minProximity(int nbChars) => this[_keyMinProximity] = nbChars;

  int get minProximity => AbstractQuery.parseInt(this[_keyMinProximity]);

  /// Specify the minimum number of characters in a query word to accept one
  /// typo in this word.
  ///
  /// Defaults to 3.
  set minWordSizeFor1Typo(int nbChars) =>
      this[_keyMinWordSizeFor1Typo] = nbChars;

  int get minWordSizeFor1Typo =>
      AbstractQuery.parseInt(this[_keyMinWordSizeFor1Typo]);

  /// Specify the minimum number of characters in a query word to accept one
  /// typo in this word.
  ///
  /// Defaults to 3.
  set minWordSizeFor2Typos(int nbChars) =>
      this[_keyMinWordSizeFor2Typos] = nbChars;

  int get minWordSizeFor2Typos {
    return AbstractQuery.parseInt(this[_keyMinWordSizeFor2Typos]);
  }

  /// Set the offset of the first hit to return (zero-based).
  ///
  /// In most cases, [page] page}/[hitsPerPage] hitsPerPage is the
  /// recommended method for pagination.
  ///
  /// [offset] a zero-based offset.
  set offset(int offset) => this[_keyOffset] = offset;

  int get offset => AbstractQuery.parseInt(this[_keyOffset]);

  /// Set a list of words that should be considered as optional when found in
  /// the query.
  ///
  /// [words] the list of optional words.

  set optionalWords(List<String> words) =>
      this[_keyOptionalWords] = AbstractQuery.buildJSONArray(words);

  List<String> get optionalWords =>
      AbstractQuery.parseArray(this[_keyOptionalWords]);

  /// Set a list of filters for ranking purposes, to rank higher records that
  /// contain the filter(s).
  ///
  /// [filters] the list of optional filters.
  set optionalFilters(List<String> filters) =>
      this[_keyOptionalFilters] = AbstractQuery.buildJSONArray(filters);

  List<String> get optionalFilters {
    return AbstractQuery.parseArray(this[_keyOptionalFilters]);
  }

  /// Set the page to retrieve (zero base).
  ///
  /// Defaults to 0.
  set page(int page) => this[_keyPage] = page;

  int get page => AbstractQuery.parseInt(this[_keyPage]);

  /// Whether to include the query in processing time percentile computation.
  ///
  /// [enabled] if true, the API records the processing time of the search query
  /// and includes it when computing the 90% and 99% percentiles, available in
  /// your Algolia dashboard. When `false`, the search query is excluded from
  /// percentile computation.
  set percentileComputation(bool enabled) =>
      this[_keyPercentileComputation] = enabled;

  bool get percentileComputation =>
      AbstractQuery.parseBool(this[_keyPercentileComputation]);

  /// Set the full text query
  set query(String query) => this[_keyQuery] = query;

  String get query => this[_keyQuery];

  /// Select how the query words are interpreted:
  set queryType(QueryType type) =>
      this[_keyQueryType] = type == null ? null : type.toString();

  QueryType get queryType {
    final String value = this[_keyQueryType];
    return value == null ? null : QueryType.fromString(value);
  }

  /// Enable the removal of stop words, disabled by default.
  ///
  /// In most use-cases, we don’t recommend enabling this option.
  ///
  /// [removeStopWords]
  /// - bool:   enable or disable all 41 supported languages,
  /// - String: comma separated list of languages you have in your record
  ///           (using language iso code).
  set removeStopWords(Object removeStopWords) {
    if (removeStopWords is bool || removeStopWords is String) {
      this[_keyRemoveStopWords] = removeStopWords;
    } else {
      throw AlgoliaException(
          'removeStopWords should be a bool or a String but it was ${removeStopWords.runtimeType}.');
    }
  }

  Object get removeStopWords {
    final String value = this[_keyRemoveStopWords];
    if (value == null) {
      return null;
    }
    final List<String> commaArray = AbstractQuery.parseCommaArray(value);
    if (commaArray.length == 1 &&
        (commaArray[0] == 'false' || commaArray[0] == 'true')) {
      return AbstractQuery.parseBool(value);
    }
    return commaArray;
  }

  /// Select the strategy to adopt when a query does not return any result.
  set removeWordsIfNoResults(RemoveWordsIfNoResults type) {
    this[_keyRemoveWordsIfNoResults] = type == null ? null : type.toString();
  }

  RemoveWordsIfNoResults get removeWordsIfNoResults {
    final String value = this[_keyRemoveWordsIfNoResults];
    return value == null ? null : RemoveWordsIfNoResults.fromString(value);
  }

  /// If [enabled] is set to false, words matched via synonyms expansion will
  /// not be replaced by the matched synonym in highlight result. Default to
  /// true.
  set replaceSynonymsInHighlight(bool enabled) =>
      this[_keyReplaceSynonymsInHighlight] = enabled;

  bool get replaceSynonymsInHighlight =>
      AbstractQuery.parseBool(this[_keyReplaceSynonymsInHighlight]);

  /// Restricts arrays in highlight and snippet results to items that matched
  /// the query.
  ///
  /// [restrict] if false, all array items are highlighted/snippeted. When true,
  /// only array items that matched at least partially are
  /// highlighted/snippeted.
  set restrictHighlightAndSnippetArrays(bool restrict) =>
      this[_keyRestrictHighlightAndSnippetArrays] = restrict;

  bool get restrictHighlightAndSnippetArrays =>
      AbstractQuery.parseBool(this[_keyRestrictHighlightAndSnippetArrays]);

  /// List of object attributes you want to use for textual search (must be a
  /// subset of the searchableAttributes index setting). Attributes are
  /// separated with a comma (for example @'name,address'). You can also use a
  /// JSON string array encoding (for example
  /// encodeURIComponent('[\'name\',\'address\']')).
  ///
  /// By default, all attributes specified in searchableAttributes settings
  /// are used to search.
  set restrictSearchableAttributes(List<String> attributes) =>
      this[_keyRestrictSearchableAttributes] =
          AbstractQuery.buildJSONArray(attributes);

  List<String> get restrictSearchableAttributes {
    return AbstractQuery.parseArray(this[_keyRestrictSearchableAttributes]);
  }

  /// Set a list of contexts for which rules are enabled.
  ///
  /// <p>
  /// Contextual rules matching any of these contexts are eligible, as well as
  /// generic rules. When empty, only generic rules are eligible.
  ///
  /// [ruleContexts] one or several contexts.
  set ruleContexts(List<String> ruleContexts) =>
      this[_keyRuleContexts] = AbstractQuery.buildJSONArray(ruleContexts);

  List<String> get ruleContexts =>
      AbstractQuery.parseArray(this[_keyRuleContexts]);

  /// Specify the string that is used as an ellipsis indicator when a snippet
  /// is truncated.
  ///
  /// Defaults to the empty string.
  set snippetEllipsisText(String snippetEllipsisText) =>
      this[_keySnippetEllipsisText] = snippetEllipsisText;

  String get snippetEllipsisText => this[_keySnippetEllipsisText];

  /// When using [facets], Algolia retrieves a list of matching facet values
  /// for each faceted attribute. This parameter controls how the facet values
  /// are sorted within each faceted attribute.
  ///
  /// [order] supported options are [SortFacetValuesBy.count] (sort by
  /// decreasing count) and [SortFacetValuesBy.alpha] (sort by increasing
  /// alphabetical order)
  set sortFacetValuesBy(SortFacetValuesBy order) =>
      this[_keySortFacetValuesBy] = order.toString();

  SortFacetValuesBy get sortFacetValuesBy =>
      SortFacetValuesBy.fromString(this[_keySortFacetValuesBy]);

  /// [enabled] false means that the total score of a record is the maximum
  /// score of an individual filter. Setting it to true changes the total score
  /// by adding together the scores of each filter found.
  ///
  /// Defaults to false.
  set sumOrFiltersScores(bool enabled) =>
      this[_keySumOrFiltersScores] = enabled;

  bool get sumOrFiltersScores =>
      AbstractQuery.parseBool(this[_keySumOrFiltersScores]);

  /// [enabled] if set to false, this query will not use synonyms defined in
  /// configuration.
  ///
  /// Defaults to true.
  set synonyms(bool enabled) => this[_keySynonyms] = enabled;

  bool get synonyms => AbstractQuery.parseBool(this[_keySynonyms]);

  set tagFilters(List<dynamic> tagFilters) =>
      this[_keyTagFilters] = jsonEncode(tagFilters);

  List<dynamic> get tagFilters {
    try {
      final String value = this[_keyTagFilters];
      if (value != null) {
        final List<dynamic> result = jsonDecode(value);
        return result;
      }
    } catch (e) {
      rethrow;
      // Will return null
    }
    return null;
  }

  set typoTolerance(TypoTolerance type) {
    this[_keyTypoTolerance] = type == null ? null : type.toString();
  }

  TypoTolerance get typoTolerance {
    final String value = this[_keyTypoTolerance];
    return value == null ? null : TypoTolerance.fromString(value);
  }

  set exactOnSingleWordQuery(ExactOnSingleWordQuery type) =>
      this[_keyExactOnSingleWordQuery] = type == null ? null : type.toString();

  ExactOnSingleWordQuery get exactOnSingleWordQuery {
    final String value = this[_keyExactOnSingleWordQuery];
    return value == null ? null : ExactOnSingleWordQuery.fromString(value);
  }

  /// [enabled] if set to false, rules processing is disabled: no rule will
  /// match the query.
  ///
  /// Defaults to true.
  set enableRules(bool enabled) => this[_keyEnableRules] = enabled;

  bool get enableRules => AbstractQuery.parseBool(this[_keyEnableRules]);

  set alternativesAsExact(List<AlternativesAsExact> types) {
    if (types == null) {
      this[_keyAlternativesAsExact] = null;
    } else {
      this[_keyAlternativesAsExact] = types.join(',');
    }
  }

  List<AlternativesAsExact> get alternativesAsExact {
    final String alternativesStr = this[_keyAlternativesAsExact];
    if (alternativesStr == null) {
      return null;
    } else if (alternativesStr.isEmpty) {
      return <AlternativesAsExact>[];
    }

    return alternativesStr
        .split(',')
        .map(AlternativesAsExact.fromString)
        .toList();
  }

  /// Choose which fields the response will contain. Applies to search and
  /// browse queries.
  ///
  /// <p>
  /// By default, all fields are returned. If this parameter is specified, only
  /// the fields explicitly listed will be returned, unless * is used, in which
  /// case all fields are returned. Specifying an empty list or unknown field
  /// names is an error.
  set responseFields(List<String> attributes) =>
      this[_keyResponseFields] = AbstractQuery.buildJSONArray(attributes);

  /// Get the fields the response will contain. If unspecified, all fields are
  /// returned.
  List<String> get responseFields =>
      AbstractQuery.parseArray(this[_keyResponseFields]);
}

class QueryType {
  const QueryType._(this._i);

  final int _i;

  /// All query words are interpreted as prefixes.
  static const QueryType prefixAll = QueryType._(0);

  /// Only the last word is interpreted as a prefix.
  static const QueryType prefixLast = QueryType._(1);

  /// No query word is interpreted as a prefix. This option is not recommended.
  static const QueryType prefixNone = QueryType._(2);

  static const List<QueryType> values = <QueryType>[
    prefixAll,
    prefixLast,
    prefixNone,
  ];

  static const List<String> _stringValues = <String>[
    'prefixAll',
    'prefixLast',
    'prefixNone',
  ];

  static QueryType fromString(String value) {
    final int i = _stringValues.indexOf(value);

    if (i == -1) {
      return null;
    }

    return values[i];
  }

  @override
  String toString() => _stringValues[_i];
}

class RemoveWordsIfNoResults {
  const RemoveWordsIfNoResults._(this._i);

  final int _i;

  static const RemoveWordsIfNoResults lastWords = RemoveWordsIfNoResults._(0);
  static const RemoveWordsIfNoResults firstWords = RemoveWordsIfNoResults._(1);
  static const RemoveWordsIfNoResults allOptional = RemoveWordsIfNoResults._(2);
  static const RemoveWordsIfNoResults none = RemoveWordsIfNoResults._(3);

  static const List<RemoveWordsIfNoResults> values = <RemoveWordsIfNoResults>[
    lastWords,
    firstWords,
    allOptional,
    none,
  ];

  static const List<String> _stringValues = <String>[
    'lastWords',
    'firstWords',
    'allOptional',
    'none',
  ];

  static RemoveWordsIfNoResults fromString(String value) {
    final int i = _stringValues.indexOf(value);

    if (i == -1) {
      return null;
    }

    return values[i];
  }

  @override
  String toString() => _stringValues[_i];
}

class TypoTolerance {
  const TypoTolerance._(this._i);

  final int _i;

  static const TypoTolerance setTrue = TypoTolerance._(0);
  static const TypoTolerance setFalse = TypoTolerance._(1);
  static const TypoTolerance min = TypoTolerance._(2);
  static const TypoTolerance strict = TypoTolerance._(3);

  static const List<TypoTolerance> values = <TypoTolerance>[
    setTrue,
    setFalse,
    min,
    strict,
  ];

  static const List<String> _stringValues = <String>[
    'true',
    'false',
    'min',
    'strict',
  ];

  static TypoTolerance fromString(String value) {
    final int i = _stringValues.indexOf(value);

    if (i == -1) {
      return null;
    }

    return values[i];
  }

  @override
  String toString() => _stringValues[_i];
}

class ExactOnSingleWordQuery {
  const ExactOnSingleWordQuery._(this._i);

  final int _i;

  static const ExactOnSingleWordQuery none = ExactOnSingleWordQuery._(0);
  static const ExactOnSingleWordQuery word = ExactOnSingleWordQuery._(1);
  static const ExactOnSingleWordQuery attribute = ExactOnSingleWordQuery._(2);

  static const List<ExactOnSingleWordQuery> values = <ExactOnSingleWordQuery>[
    none,
    word,
    attribute,
  ];

  static const List<String> _stringValues = <String>[
    'none',
    'word',
    'attribute',
  ];

  static ExactOnSingleWordQuery fromString(String value) {
    final int i = _stringValues.indexOf(value);

    if (i == -1) {
      return null;
    }

    return values[i];
  }

  @override
  String toString() => _stringValues[_i];
}

class AlternativesAsExact {
  const AlternativesAsExact._(this._i);

  final int _i;

  static const AlternativesAsExact ignorePlurals = AlternativesAsExact._(0);
  static const AlternativesAsExact singleWordSynonym = AlternativesAsExact._(1);
  static const AlternativesAsExact multiWordsSynonym = AlternativesAsExact._(2);

  static const List<AlternativesAsExact> values = <AlternativesAsExact>[
    ignorePlurals,
    singleWordSynonym,
    multiWordsSynonym,
  ];

  static const List<String> _stringValues = <String>[
    'ignorePlurals',
    'singleWordSynonym',
    'multiWordsSynonym',
  ];

  static AlternativesAsExact fromString(String value) {
    final int i = _stringValues.indexOf(value);

    if (i == -1) {
      return null;
    }

    return values[i];
  }

  @override
  String toString() => _stringValues[_i];
}

class SortFacetValuesBy {
  const SortFacetValuesBy._(this._i);

  final int _i;

  static const SortFacetValuesBy alpha = SortFacetValuesBy._(0);
  static const SortFacetValuesBy count = SortFacetValuesBy._(1);

  static const List<SortFacetValuesBy> values = <SortFacetValuesBy>[
    alpha,
    count,
  ];

  static const List<String> _stringValues = <String>[
    'alpha',
    'count',
  ];

  static SortFacetValuesBy fromString(String value) {
    final int i = _stringValues.indexOf(value);

    if (i == -1) {
      return null;
    }

    return values[i];
  }

  @override
  String toString() => _stringValues[_i];
}

/// A value of the [Query._keyIgnorePlurals] setting.
///
/// Can represent either a bool or a list of language codes,
/// see https://www.algolia.com/doc/faq/searching/how-does-ignoreplurals-work.
class IgnorePlurals {
  /// Construct an [IgnorePlurals] object for a bool value.
  ///
  /// [enabled] if true, the engine will ignore plurals in all supported
  /// languages.
  const IgnorePlurals({@required this.enabled}) : languageCodes = null;

  /// Construct an IgnorePlurals object for a [List] of language codes.
  ///
  /// [codes] is a list of language codes to ignore plurals from. if null, the
  /// engine will ignore plurals in all supported languages.
  factory IgnorePlurals.fromCodes(List<String> codes) {
    final bool enabled = !(codes == null || codes.isEmpty);
    final List<String> languageCodes =
        codes != null ? List<String>.from(codes) : null;

    return IgnorePlurals._(enabled, languageCodes);
  }

  factory IgnorePlurals.parse(String s) {
    if (s == null || s.isEmpty || s == 'null') {
      return const IgnorePlurals(enabled: false);
    } else if ('true' == s || 'false' == s) {
      return IgnorePlurals(enabled: AbstractQuery.parseBool(s));
    } else {
      final List<String> codesList = <String>[];
      //ignorePlurals=['en','fi']
      try {
        final List<String> codes = jsonDecode(s).cast<String>();
        for (int i = 0; i < codes.length; i++) {
          codesList.add(codes[i].toString());
        }
        return IgnorePlurals.fromCodes(codesList);
      } catch (e) {
        // s was not a JSONArray of strings. Maybe it is a comma-separated list?
        final List<String> split = s.split(',');
        if (split != null && split.isNotEmpty) {
          codesList.addAll(split);
          return IgnorePlurals.fromCodes(codesList);
        } else {
          throw StateError(
              'Error while parsing `$s: invalid ignorePlurals value.');
        }
      }
    }
  }

  IgnorePlurals._(this.enabled, this.languageCodes);

  /// If set to true, plural won't be considered as a typo (for example car/cars
  /// will be considered as equals).
  ///
  /// Defaults to false.
  final bool enabled;

  /// A list containing every active language's code. When null, all supported
  /// languages are be used.
  ///
  /// A list of language codes for which plural won't be considered as a typo
  /// (for example car/cars will be considered as equals). If empty or null,
  /// this disables the feature.
  final List<String> languageCodes;

  @override
  String toString() {
    if (!enabled) {
      return 'false';
    } else {
      if (languageCodes == null || languageCodes.isEmpty) {
        // enabled without specific language
        return 'true';
      } else {
        return languageCodes.join(',');
      }
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IgnorePlurals &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          const ListEquality<String>()
              .equals(languageCodes, other.languageCodes);

  @override
  int get hashCode =>
      enabled.hashCode ^ const ListEquality<String>().hash(languageCodes);
}

/// A rectangle in geo coordinates. Used in geo-search.
class GeoRect {
  const GeoRect(this.p1, this.p2);

  final LatLng p1;

  final LatLng p2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoRect &&
          runtimeType == other.runtimeType &&
          p1 == other.p1 &&
          p2 == other.p2;

  @override
  int get hashCode => p1.hashCode ^ p2.hashCode;
}

/// A polygon in geo coordinates. Used in geo-search.
class Polygon {
  Polygon(this.points)
      : assert(
            points.length <= 3, 'A polygon must have at least three vertices.');

  Polygon.copy(Polygon other) : points = other.points;

  factory Polygon.parse(String value) {
    if (value != null) {
      final List<String> fields = value.split(',');
      if (fields.length % 2 == 0 && fields.length / 2 >= 3) {
        final List<LatLng> result = <LatLng>[]..length = fields.length ~/ 2;
        for (int i = 0; i < result.length; ++i) {
          result[i] = LatLng(
              double.parse(fields[2 * i]), double.parse(fields[2 * i + 1]));
        }
        return Polygon(result);
      }
    }
    return null;
  }

  final List<LatLng> points;

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();
    for (LatLng point in points) {
      if (sb.isNotEmpty) {
        sb.write(',');
      }
      sb..write(point.lat)..write(',')..write(point.lng);
    }
    return sb.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Polygon &&
          runtimeType == other.runtimeType &&
          const ListEquality<LatLng>().equals(points, other.points);

  @override
  int get hashCode => const ListEquality<LatLng>().hash(points);
}
