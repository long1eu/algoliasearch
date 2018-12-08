// File created by
// Lung Razvan <long1eu>
// on 2018-12-08

import 'dart:mirrors';

import 'package:algoliasearch/src/abstract_query.dart';
import 'package:algoliasearch/src/algolia_exception.dart';
import 'package:algoliasearch/src/query.dart';
import 'package:test/test.dart';

void main() {
  /// Test serializing a query into a URL query string.
  test('build', () async {
    final Query query = Query();
    query['c'] = 'C';
    query['b'] = 'B';
    query['a'] = 'A';
    final String queryString = query.build();
    expect(queryString, 'a=A&b=B&c=C');
  });

  /// Test parsing a query from a URL query string.
  test('parse', () async {
    // Build the URL for a query.
    final Query query = Query();
    query['foo'] = 'bar';
    query['abc'] = 'xyz';
    final String queryString = query.build();

    // Parse the URL into another query.
    expect(Query.parse(queryString), query);
  });

  /// Test that non-ASCII and special characters are escaped.
  test('escape', () async {
    final Query query = Query();
    query['accented'] = 'éêèàôù';
    query['escaped'] = ' %&=#+';
    final String queryString = query.build();
    expect(queryString,
        'accented=%C3%A9%C3%AA%C3%A8%C3%A0%C3%B4%C3%B9&escaped=%20%25%26%3D%23%2B');

    // Test parsing of escaped characters.
    expect(Query.parse(queryString), query);
  });

  // endregion
  // region Low-level

  /// Test low-level accessors.
  test('getSet', () async {
    final Query query = Query();

    // Test accessors.
    query['a'] = 'A';
    expect(query['a'], 'A');

    // Test setting null.
    query['a'] = null;
    expect(query['a'], isNull);
    query['b'] = null;
    expect(query['b'], isNull);
  });

  dynamic getter(Object object, String name) {
    return reflect(object).getField(Symbol(name)).reflectee;
  }

  void setter(Object object, String name, Object value) {
    reflect(object).setField(Symbol(name), value);
  }

  void testBooleanAttribute(String name) {
    final Query query = Query();

    // Default value
    expect(getter(query, name), isNull,
        reason: 'By default, $name should be null.');

    // Boolean values
    setter(query, name, true);
    expect(getter(query, name), isTrue,
        reason: 'A true boolean should enable $name');
    expect(query[name], 'true', reason: 'A true boolean should be in $name');
    expect(getter(query, name), getter(Query.parse(query.build()), name),
        reason: 'A true boolean should be built and parsed correctly');

    setter(query, name, false);
    expect(getter(query, name), isFalse,
        reason: 'A false boolean should enable $name');
    expect(query[name], 'false', reason: 'A false boolean should be in $name');
    expect(getter(query, name), getter(Query.parse(query.build()), name),
        reason: 'A false boolean should be built and parsed correctly');

    setter(query, name, null);
    expect(getter(query, name), isNull,
        reason: 'A null boolean should disable $name');
    expect(query[name], isNull, reason: 'A null boolean should be in $name');
    expect(getter(query, name), getter(Query.parse(query.build()), name),
        reason: 'A null boolean should be built and parsed correctly');
  }

  test('advancedSyntax', () async {
    testBooleanAttribute('advancedSyntax');
  });

  test('aroundLatLngViaIP', () async {
    testBooleanAttribute('aroundLatLngViaIP');
  });

  test('allowTyposOnNumericTokens', () async {
    testBooleanAttribute('allowTyposOnNumericTokens');
  });

  test('analytics', () async {
    testBooleanAttribute('analytics');
  });

  test('clickAnalytics', () async {
    testBooleanAttribute('clickAnalytics');
  });

  test('enableRules', () async {
    testBooleanAttribute('enableRules');
  });

  test('facetingAfterDistinct', () async {
    testBooleanAttribute('facetingAfterDistinct');
  });

  test('getRankingInfo', () async {
    testBooleanAttribute('getRankingInfo');
  });

  test('percentileComputation', () async {
    testBooleanAttribute('percentileComputation');
  });

  test('replaceSynonymsInHighlight', () async {
    testBooleanAttribute('replaceSynonymsInHighlight');
  });

  test('restrictHighlightAndSnippetArrays', () async {
    testBooleanAttribute('restrictHighlightAndSnippetArrays');
  });

  test('sumOrFiltersScores', () async {
    testBooleanAttribute('sumOrFiltersScores');
  });

  test('synonyms', () async {
    testBooleanAttribute('synonyms');
  });

  // TODO: Either categorise or restructure tests differently
  test('minWordSizefor1Typo', () async {
    final Query query = Query();
    expect(query.minWordSizeFor1Typo, isNull);
    query.minWordSizeFor1Typo = 123;
    expect(query.minWordSizeFor1Typo, 123);
    expect(query['minWordSizefor1Typo'], '123');
    expect(Query.parse(query.build()).minWordSizeFor1Typo,
        query.minWordSizeFor1Typo);
  });

  test('minWordSizeFor2Typos', () async {
    final Query query = Query();
    expect(query.minWordSizeFor2Typos, isNull);
    query.minWordSizeFor2Typos = 456;
    expect(query.minWordSizeFor2Typos, 456);
    expect(query['minWordSizefor2Typos'], '456');
    expect(Query.parse(query.build()).minWordSizeFor2Typos,
        query.minWordSizeFor2Typos);
  });

  test('minProximity', () async {
    final Query query = Query();
    expect(query.minProximity, isNull);
    query.minProximity = 999;
    expect(query.minProximity, 999);
    expect(query['minProximity'], '999');
    expect(Query.parse(query.build()).minProximity, query.minProximity);
  });

  test('ignorePlurals', () async {
    // No value
    final Query query = Query();
    expect(query.ignorePlurals.enabled, isFalse,
        reason: 'By default, ignorePlurals should be disabled.');

    // Boolean values
    query.ignorePlurals = const IgnorePlurals(enabled: true);
    expect(query.ignorePlurals.enabled, isTrue,
        reason: 'A true boolean should enable ignorePlurals.');
    expect(query['ignorePlurals'], 'true',
        reason: 'A true boolean should be in ignorePlurals.');
    expect(query.ignorePlurals, Query.parse(query.build()).ignorePlurals,
        reason: 'A true boolean should be built and parsed successfully.');

    query.ignorePlurals = const IgnorePlurals(enabled: false);
    expect(query.ignorePlurals.enabled, isFalse,
        reason: 'A false boolean should disable ignorePlurals.');
    expect(query['ignorePlurals'], 'false',
        reason: 'A false boolean should should be in ignorePlurals.');
    expect(query.ignorePlurals, Query.parse(query.build()).ignorePlurals,
        reason: 'A false boolean should be built and parsed successfully.');

    query.ignorePlurals = null;
    expect(query.ignorePlurals.enabled, isFalse,
        reason: 'A null boolean should disable ignorePlurals.');
    expect(query['ignorePlurals'], isNull,
        reason: 'A null boolean should be in ignorePlurals.');
    expect(query.ignorePlurals, Query.parse(query.build()).ignorePlurals,
        reason: 'A null boolean should be built and parsed successfully.');

    // List values
    query.ignorePlurals = IgnorePlurals.fromCodes(<String>[]);
    expect(query.ignorePlurals.enabled, isFalse,
        reason: 'Setting an empty list should disable ignorePlurals.');

    final List<String> languageCodes = <String>['en', 'fr'];
    query.ignorePlurals = IgnorePlurals.fromCodes(languageCodes);
    expect(query.ignorePlurals.enabled, isTrue,
        reason: 'Setting a non-empty list should enable ignorePlurals.');
    expect(query['ignorePlurals'], 'en,fr',
        reason: 'Setting a non-empty list should be in ignorePlurals.');
    expect(query.ignorePlurals.languageCodes, isNotNull,
        reason: 'The language codes should not be null');
    expect(query.ignorePlurals.languageCodes.length, 2,
        reason: 'Two language codes should be in ignorePlurals.');
    expect(query.ignorePlurals.languageCodes.contains(languageCodes[0]), isTrue,
        reason: 'The first language code should be in ignorePlurals');
    expect(query.ignorePlurals.languageCodes.contains(languageCodes[1]), isTrue,
        reason: 'The second language code should be in ignorePlurals');

    query.ignorePlurals = IgnorePlurals.fromCodes(null);
    expect(query.ignorePlurals.enabled, isFalse,
        reason: 'A null list value should disable ignorePlurals.');
    expect(query['ignorePlurals'], 'false',
        reason: 'A null list value should disable ignorePlurals.');
    expect(query.ignorePlurals, Query.parse(query.build()).ignorePlurals,
        reason: 'A null list value should be built and parsed successfully.');
  });

  test('distinct', () async {
    final Query query = Query();
    expect(query.distinct, isNull);
    query.distinct = 100;
    expect(query.distinct, 100);
    expect(query['distinct'], '100');
    expect(Query.parse(query.build()).distinct, query.distinct);
  });

  test('page', () async {
    final Query query = Query();
    expect(query.page, isNull);
    query.page = 0;
    expect(query.page, 0);
    expect(query['page'], '0');
    expect(Query.parse(query.build()).page, query.page);
  });

  test('hitsPerPage', () async {
    final Query query = Query();
    expect(query.hitsPerPage, isNull);
    query.hitsPerPage = 50;
    expect(query.hitsPerPage, 50);
    expect(query['hitsPerPage'], '50');
    expect(Query.parse(query.build()).hitsPerPage, query.hitsPerPage);
  });

  test('sortFacetValuesBy', () async {
    final Query query = Query();
    expect(query.sortFacetValuesBy, isNull);
    query.sortFacetValuesBy = SortFacetValuesBy.count;
    expect(query.sortFacetValuesBy, SortFacetValuesBy.count);
    expect(query['sortFacetValuesBy'], 'count');
    query.sortFacetValuesBy = SortFacetValuesBy.alpha;
    expect(query.sortFacetValuesBy, SortFacetValuesBy.alpha);
    expect(query['sortFacetValuesBy'], 'alpha');
    final Query query2 = Query.parse(query.build());
    expect(query2.sortFacetValuesBy, query.sortFacetValuesBy);
  });

  test('attributesToHighlight', () async {
    final Query query = Query();
    expect(query.attributesToHighlight, isNull);
    query.attributesToHighlight = <String>['foo', 'bar'];
    expect(
      query.attributesToHighlight,
      orderedEquals(<String>['foo', 'bar']),
    );
    expect(query['attributesToHighlight'], '[\"foo\",\"bar\"]');
    expect(Query.parse(query.build()).attributesToHighlight,
        orderedEquals(query.attributesToHighlight));

    query.attributesToHighlight = <String>['foo', 'bar'];
    expect(query.attributesToHighlight, orderedEquals(<String>['foo', 'bar']));
    expect(query['attributesToHighlight'], '[\"foo\",\"bar\"]');
    expect(Query.parse(query.build()).attributesToHighlight,
        orderedEquals(query.attributesToHighlight));
  });

  test('attributesToRetrieve', () async {
    final Query query = Query();
    expect(query.attributesToRetrieve, isNull);
    query.attributesToRetrieve = <String>['foo', 'bar'];
    expect(query.attributesToRetrieve, orderedEquals(<String>['foo', 'bar']));
    expect(query['attributesToRetrieve'], '[\"foo\",\"bar\"]');
    expect(Query.parse(query.build()).attributesToRetrieve,
        orderedEquals(query.attributesToRetrieve));

    query.attributesToRetrieve = <String>['foo', 'bar'];
    expect(query.attributesToRetrieve, orderedEquals(<String>['foo', 'bar']));
    expect(query['attributesToRetrieve'], '[\"foo\",\"bar\"]');
    expect(Query.parse(query.build()).attributesToRetrieve,
        orderedEquals(query.attributesToRetrieve));
  });

  test('attributesToSnippet', () async {
    final Query query = Query();
    expect(query.attributesToSnippet, isNull);
    query.attributesToSnippet = <String>['foo:3', 'bar:7'];
    expect(
        query.attributesToSnippet, orderedEquals(<String>['foo:3', 'bar:7']));
    expect(query['attributesToSnippet'], '[\"foo:3\",\"bar:7\"]');
    expect(Query.parse(query.build()).attributesToSnippet,
        orderedEquals(query.attributesToSnippet));
  });

  test('query', () async {
    final Query query = Query();
    expect(query.query, isNull);
    query.query = 'supercalifragilisticexpialidocious';
    expect(query.query, 'supercalifragilisticexpialidocious');
    expect(query['query'], 'supercalifragilisticexpialidocious');
    expect(Query.parse(query.build()).query, query.query);
  });

  test('queryType', () async {
    final Query query = Query();
    expect(query.queryType, isNull);

    query.queryType = QueryType.prefixAll;
    expect(query.queryType, QueryType.prefixAll);
    expect(query['queryType'], 'prefixAll');
    expect(Query.parse(query.build()).queryType, query.queryType);

    query.queryType = QueryType.prefixLast;
    expect(query.queryType, QueryType.prefixLast);
    expect(query['queryType'], 'prefixLast');
    expect(Query.parse(query.build()).queryType, query.queryType);

    query.queryType = QueryType.prefixNone;
    expect(QueryType.prefixNone, query.queryType);
    expect('prefixNone', query['queryType']);
    expect(Query.parse(query.build()).queryType, query.queryType);

    query['queryType'] = 'invalid';
    expect(query.queryType, isNull);
  });

  test('removeWordsIfNoResults', () async {
    final Query query = Query();
    expect(query.removeWordsIfNoResults, isNull);

    query.removeWordsIfNoResults = RemoveWordsIfNoResults.allOptional;
    expect(query.removeWordsIfNoResults, RemoveWordsIfNoResults.allOptional);
    expect(query['removeWordsIfNoResults'], 'allOptional');
    expect(Query.parse(query.build()).removeWordsIfNoResults,
        query.removeWordsIfNoResults);

    query.removeWordsIfNoResults = RemoveWordsIfNoResults.firstWords;
    expect(query.removeWordsIfNoResults, RemoveWordsIfNoResults.firstWords);
    expect(query['removeWordsIfNoResults'], 'firstWords');
    expect(Query.parse(query.build()).removeWordsIfNoResults,
        query.removeWordsIfNoResults);

    query.removeWordsIfNoResults = RemoveWordsIfNoResults.lastWords;
    expect(query.removeWordsIfNoResults, RemoveWordsIfNoResults.lastWords);
    expect(query['removeWordsIfNoResults'], 'lastWords');
    expect(Query.parse(query.build()).removeWordsIfNoResults,
        query.removeWordsIfNoResults);

    query.removeWordsIfNoResults = RemoveWordsIfNoResults.none;
    expect(query.removeWordsIfNoResults, RemoveWordsIfNoResults.none);
    expect(query['removeWordsIfNoResults'], 'none');
    expect(Query.parse(query.build()).removeWordsIfNoResults,
        query.removeWordsIfNoResults);

    query['removeWordsIfNoResults'] = 'invalid';
    expect(query.removeWordsIfNoResults, isNull);

    query['removeWordsIfNoResults'] = 'allOptional';
    expect(query.removeWordsIfNoResults, RemoveWordsIfNoResults.allOptional);
  });

  test('typoTolerance', () async {
    final Query query = Query();
    expect(query.typoTolerance, isNull);

    query.typoTolerance = TypoTolerance.setTrue;
    expect(query.typoTolerance, TypoTolerance.setTrue);
    expect(query['typoTolerance'], 'true');
    expect(Query.parse(query.build()).typoTolerance, query.typoTolerance);

    query.typoTolerance = TypoTolerance.setFalse;
    expect(query.typoTolerance, TypoTolerance.setFalse);
    expect(query['typoTolerance'], 'false');
    expect(Query.parse(query.build()).typoTolerance, query.typoTolerance);

    query.typoTolerance = TypoTolerance.min;
    expect(query.typoTolerance, TypoTolerance.min);
    expect(query['typoTolerance'], 'min');
    expect(Query.parse(query.build()).typoTolerance, query.typoTolerance);

    query.typoTolerance = TypoTolerance.strict;
    expect(query.typoTolerance, TypoTolerance.strict);
    expect(query['typoTolerance'], 'strict');
    expect(Query.parse(query.build()).typoTolerance, query.typoTolerance);

    query['typoTolerance'] = 'invalid';
    expect(query.typoTolerance, isNull);

    query['typoTolerance'] = 'true';
    expect(query.typoTolerance, TypoTolerance.setTrue);
  });

  test('facets', () async {
    final Query query = Query();
    expect(query.facets, isNull);
    query.facets = <String>['foo', 'bar'];
    expect(query.facets, orderedEquals(<String>['foo', 'bar']));
    expect(query['facets'], '[\"foo\",\"bar\"]');
    final Query query2 = Query.parse(query.build());
    expect(query2.facets, orderedEquals(query.facets));
  });

  test('offset', () async {
    final Query query = Query();
    expect(query.offset, isNull);
    query.offset = 0;
    expect(query.offset, 0);
    expect(query['offset'], '0');
    expect(Query.parse(query.build()).offset, query.offset);
  });

  test('optionalWords', () async {
    final Query query = Query();
    expect(query.optionalWords, isNull);
    query.optionalWords = <String>['foo', 'bar'];
    expect(query.optionalWords, orderedEquals(<String>['foo', 'bar']));
    expect(query['optionalWords'], '[\"foo\",\"bar\"]');
    expect(Query.parse(query.build()).optionalWords,
        orderedEquals(query.optionalWords));
  });

  test('optionalFilters', () async {
    final Query query = Query();
    expect(query.optionalFilters, isNull);
    query.optionalFilters = <String>['foo', 'bar'];
    expect(query.optionalFilters, orderedEquals(<String>['foo', 'bar']));
    expect(query['optionalFilters'], '[\"foo\",\"bar\"]');
    expect(Query.parse(query.build()).optionalFilters,
        orderedEquals(query.optionalFilters));
  });

  test('restrictSearchableAttributes', () async {
    final Query query = Query();
    expect(query.restrictSearchableAttributes, isNull);
    query.restrictSearchableAttributes = <String>['foo', 'bar'];
    expect(query.restrictSearchableAttributes,
        orderedEquals(<String>['foo', 'bar']));
    expect(query['restrictSearchableAttributes'], '[\"foo\",\"bar\"]');
    expect(Query.parse(query.build()).restrictSearchableAttributes,
        orderedEquals(query.restrictSearchableAttributes));
  });

  test('highlightPreTag', () async {
    final Query query = Query();
    expect(query.highlightPreTag, isNull);
    query.highlightPreTag = '<PRE[';
    expect(query.highlightPreTag, '<PRE[');
    expect(query['highlightPreTag'], '<PRE[');
    expect(Query.parse(query.build()).highlightPreTag, query.highlightPreTag);
  });

  test('highlightPostTag', () async {
    final Query query = Query();
    expect(query.highlightPostTag, isNull);
    query.highlightPostTag = ']POST>';
    expect(query.highlightPostTag, ']POST>');
    expect(query['highlightPostTag'], ']POST>');
    expect(Query.parse(query.build()).highlightPostTag, query.highlightPostTag);
  });

  test('snippetEllipsisText', () async {
    final Query query = Query();
    expect(query.snippetEllipsisText, isNull);
    query.snippetEllipsisText = '…';
    expect(query.snippetEllipsisText, '…');
    expect(query['snippetEllipsisText'], '…');
    final Query query2 = Query.parse(query.build());
    expect(query2.snippetEllipsisText, query.snippetEllipsisText);
  });

  test('analyticsTags', () async {
    final Query query = Query();
    expect(query.analyticsTags, isNull);
    query.analyticsTags = <String>['foo', 'bar'];
    expect(query.analyticsTags, orderedEquals(<String>['foo', 'bar']));
    expect(query['analyticsTags'], '[\"foo\",\"bar\"]');
    final Query query2 = Query.parse(query.build());
    expect(query2.analyticsTags, orderedEquals(query.analyticsTags));
  });

  test('disableExactOnAttributes', () async {
    final Query query = Query();
    expect(query.disableExactOnAttributes, isNull);
    query.disableExactOnAttributes = <String>['foo', 'bar'];
    expect(
        query.disableExactOnAttributes, orderedEquals(<String>['foo', 'bar']));
    expect(query['disableExactOnAttributes'], '[\"foo\",\"bar\"]');
    final Query query2 = Query.parse(query.build());
    expect(query2.disableExactOnAttributes,
        orderedEquals(query.disableExactOnAttributes));
  });

  test('disableTypoToleranceOnAttributes', () async {
    final Query query = Query();
    expect(query.disableTypoToleranceOnAttributes, isNull);
    query.disableTypoToleranceOnAttributes = <String>['foo', 'bar'];
    expect(query.disableTypoToleranceOnAttributes,
        orderedEquals(<String>['foo', 'bar']));
    expect(query['disableTypoToleranceOnAttributes'], '[\"foo\",\"bar\"]');
    final Query query2 = Query.parse(query.build());
    expect(query2.disableTypoToleranceOnAttributes,
        orderedEquals(query.disableTypoToleranceOnAttributes));
  });

  test('aroundPrecision', () async {
    final Query query = Query();
    expect(query.aroundPrecision, isNull);
    query.aroundPrecision = 12345;
    expect(query.aroundPrecision, 12345);
    expect(query['aroundPrecision'], '12345');
    final Query query2 = Query.parse(query.build());
    expect(query2.aroundPrecision, query.aroundPrecision);
  });

  test('aroundRadius', () async {
    final Query query = Query();
    expect(query.aroundRadius, isNull);
    query.aroundRadius = 987;
    expect(query.aroundRadius, 987);
    expect(query['aroundRadius'], '987');
    final Query query2 = Query.parse(query.build());
    expect(query2.aroundRadius, query.aroundRadius);
  });

  test('aroundLatLng', () async {
    final Query query = Query();
    expect(query.aroundLatLng, isNull);
    query.aroundLatLng = const LatLng(89.76, -123.45);
    expect(query.aroundLatLng, const LatLng(89.76, -123.45));
    expect(query['aroundLatLng'], '89.76,-123.45');
    expect(Query.parse(query.build()).aroundLatLng, query.aroundLatLng);
  });

  test('insideBoundingBox', () async {
    final Query query = Query();
    expect(query.insideBoundingBox, isNull);
    const GeoRect box1 =
        GeoRect(LatLng(11.111111, 22.222222), LatLng(33.333333, 44.444444));
    query.insideBoundingBox = <GeoRect>[box1];
    expect(query.insideBoundingBox, orderedEquals(<GeoRect>[box1]));
    expect(
        query['insideBoundingBox'], '11.111111,22.222222,33.333333,44.444444');
    expect(Query.parse(query.build()).insideBoundingBox,
        orderedEquals(query.insideBoundingBox));

    const GeoRect box2 =
        GeoRect(LatLng(-55.555555, -66.666666), LatLng(-77.777777, -88.888888));
    final List<GeoRect> boxes = <GeoRect>[box1, box2];
    query.insideBoundingBox = boxes;
    expect(query.insideBoundingBox, orderedEquals(boxes));
    expect(query['insideBoundingBox'],
        '11.111111,22.222222,33.333333,44.444444,-55.555555,-66.666666,-77.777777,-88.888888');
    expect(Query.parse(query.build()).insideBoundingBox,
        orderedEquals(query.insideBoundingBox));
  });

  test('insidePolygon', () async {
    final Query query = Query();
    expect(query.insidePolygon, isNull);
    final Polygon polygon = Polygon(const <LatLng>[
      LatLng(11.111111, 22.222222),
      LatLng(33.333333, 44.444444),
      LatLng(-55.555555, -66.666666)
    ]);
    List<Polygon> polygons = <Polygon>[polygon];
    query.insidePolygon = polygons;
    expect(query.insidePolygon, orderedEquals(polygons));
    expect(query['insidePolygon'],
        '11.111111,22.222222,33.333333,44.444444,-55.555555,-66.666666');
    expect(Query.parse(query.build()).insidePolygon,
        orderedEquals(query.insidePolygon));

    final Polygon polygon2 = Polygon(const <LatLng>[
      LatLng(77.777777, 88.888888),
      LatLng(99.999999, 11.111111),
      LatLng(-11.111111, -22.222222)
    ]);
    polygons = <Polygon>[polygon, polygon2];
    query.insidePolygon = polygons;

    expect(query.insidePolygon, orderedEquals(polygons));
    expect(query['insidePolygon'],
        '[[11.111111,22.222222,33.333333,44.444444,-55.555555,-66.666666],[77.777777,88.888888,99.999999,11.111111,-11.111111,-22.222222]]');
    expect(Query.parse(query.build()).insidePolygon,
        orderedEquals(query.insidePolygon));
  });

  test('tagFilters', () {
    final List<dynamic> value = <dynamic>[
      'tag1',
      <String>['tag2', 'tag3']
    ];
    final Query query = Query();
    expect(query.tagFilters, isNull);
    query.tagFilters = value;
    expect(query.tagFilters, value);
    expect(query['tagFilters'], '[\"tag1\",[\"tag2\",\"tag3\"]]');
    expect(Query.parse(query.build()).tagFilters, query.tagFilters);
  });

  test('facetFilters', () async {
    final List<dynamic> value = <dynamic>[
      <String>['category:Book', 'category:Movie'],
      'author:John Doe'
    ];
    final Query query = Query();
    expect(query.facetFilters, isNull);
    query.facetFilters = value;
    expect(query.facetFilters, value);
    expect(query['facetFilters'],
        '[[\"category:Book\",\"category:Movie\"],\"author:John Doe\"]');
    expect(Query.parse(query.build()).facetFilters, query.facetFilters);
  });

  test('removeStopWordsBoolean', () async {
    final Query query = Query();
    expect(query.removeStopWords, isNull);
    query.removeStopWords = true;
    expect(query.removeStopWords, isTrue);
    expect(query['removeStopWords'], 'true');
    expect(Query.parse(query.build()).removeStopWords, query.removeStopWords);
  });

  test('removeStopWordsString', () async {
    final Query query = Query();
    expect(query.removeStopWords, isNull);

    query.removeStopWords = 'fr,en';
    final List<Object> removeStopWords = query.removeStopWords;
    expect(removeStopWords, orderedEquals(<String>['fr', 'en']));
    expect(query['removeStopWords'], 'fr,en');

    expect(Query.parse(query.build()).removeStopWords,
        orderedEquals(query.removeStopWords as List<Object>));
  });

  test('removeStopWordsInvalidClass', () async {
    final Query query = Query();
    try {
      query.removeStopWords = 42;
    } on AlgoliaException catch (_) {
      return; //pass
    }
    fail(
        'Setting removeStopWords should throw when its parameter is neither Boolean nor String.');
  });

  test('length', () async {
    final Query query = Query();
    expect(query.length, isNull);
    query.length = 456;
    expect(query.length, 456);
    expect(query['length'], '456');
    expect(Query.parse(query.build()).length, query.length);
  });

  test('maxFacetHits', () async {
    final Query query = Query();
    expect(query.maxFacetHits, isNull);
    query.maxFacetHits = 456;
    expect(query.maxFacetHits, 456);
    expect(query['maxFacetHits'], '456');
    expect(Query.parse(query.build()).maxFacetHits, query.maxFacetHits);
  });

  test('maxValuesPerFacet', () async {
    final Query query = Query();
    expect(query.maxValuesPerFacet, isNull);
    query.maxValuesPerFacet = 456;
    expect(query.maxValuesPerFacet, 456);
    expect(query['maxValuesPerFacet'], '456');
    expect(
        Query.parse(query.build()).maxValuesPerFacet, query.maxValuesPerFacet);
  });

  test('minimumAroundRadius', () async {
    final Query query = Query();
    expect(query.minimumAroundRadius, isNull);
    query.minimumAroundRadius = 1000;
    expect(query.minimumAroundRadius, 1000);
    expect(query['minimumAroundRadius'], '1000');
    expect(Query.parse(query.build()).minimumAroundRadius,
        query.minimumAroundRadius);
  });

  test('filters', () async {
    const String value =
        'available=1 AND (category:Book OR NOT category:Ebook) AND publication_date: 1441745506 TO 1441755506 AND inStock > 0 AND author:\"John Doe\"';
    final Query query = Query();
    expect(query.filters, isNull);
    query.filters = value;
    expect(query.filters, value);
    expect(query['filters'], value);
    expect(Query.parse(query.build()).filters, query.filters);
  });

  test('exactOnSingleWordQuery', () async {
    const ExactOnSingleWordQuery value = ExactOnSingleWordQuery.attribute;
    final Query query = Query();
    expect(query.exactOnSingleWordQuery, isNull);

    query.exactOnSingleWordQuery = value;
    expect(query.exactOnSingleWordQuery, value);
    expect(query['exactOnSingleWordQuery'], 'attribute');
    expect(Query.parse(query.build()).exactOnSingleWordQuery,
        query.exactOnSingleWordQuery);
  });

  test('alternativesAsExact', () async {
    const AlternativesAsExact value1 = AlternativesAsExact.ignorePlurals;
    const AlternativesAsExact value2 = AlternativesAsExact.multiWordsSynonym;
    final List<AlternativesAsExact> values = <AlternativesAsExact>[
      value1,
      value2
    ];

    final Query query = Query();
    expect(query.alternativesAsExact, isNull);

    final List<AlternativesAsExact> list = <AlternativesAsExact>[];
    query.alternativesAsExact = list;
    expect(query.alternativesAsExact, orderedEquals(list));

    query.alternativesAsExact = values;
    expect(query.alternativesAsExact, orderedEquals(values));

    expect(query['alternativesAsExact'], 'ignorePlurals,multiWordsSynonym');

    expect(Query.parse(query.build()).exactOnSingleWordQuery,
        query.exactOnSingleWordQuery);
  });

  test('aroundRadius_all', () async {
    const int value = 3;
    final Query query = Query();
    expect(query.aroundRadius, isNull,
        reason: 'A query should have a null aroundRadius.');

    query.aroundRadius = value;
    expect(value, query.aroundRadius,
        reason:
            'After setting a query\'s aroundRadius to a given integer we should return it from getAroundRadius.');
    expect(value.toString(), query['aroundRadius'],
        reason:
            'After setting a query\'s aroundRadius to a given integer it should be in aroundRadius.');

    String queryStr = query.build();
    expect(queryStr.contains('aroundRadius=$value'), isTrue,
        reason: 'The built query should contain \'aroundRadius=$value.');

    query.aroundRadius = Query.kRadiusAll;
    expect(Query.kRadiusAll, query.aroundRadius,
        reason:
            'After setting a query\'s aroundRadius to RADIUS_ALL it should have this aroundRadius value.');
    expect(query['aroundRadius'], 'all',
        reason:
            'After setting a query\'s aroundRadius to RADIUS_ALL its aroundRadius should be equal to "all".');

    queryStr = query.build();
    expect(queryStr.contains('aroundRadius=all'), isTrue,
        reason:
            'The built query should contain \'aroundRadius=all\', not $queryStr\.');
    expect(query.aroundRadius, Query.parse(query.build()).aroundRadius,
        reason: 'The built query should be parsed and built successfully.');
  });

  test('responseFields', () async {
    final Query query = Query();
    expect(query.responseFields, isNull,
        reason: 'A query should have a null responseFields.');
    String queryStr = query.build();
    expect(queryStr.contains('responseFields'), isFalse,
        reason:
            'The built query should not contain responseFields: "$queryStr".');

    query.responseFields = <String>['*'];
    expect(query.responseFields.length, 1,
        reason:
            'After setting its responseFields to "*" getResponseFields should contain one element.');
    expect(query.responseFields[0], '*',
        reason:
            'After setting its responseFields to "*" getResponseFields should contain "*".');
    queryStr = query.build();
    String expected = 'responseFields=${Uri.encodeQueryComponent('[\"*\"]')}';
    expect(queryStr.contains(expected), isTrue,
        reason:
            'The built query should contain "$expected", but contains $queryStr.');

    query.responseFields = <String>['hits', 'page'];
    expect(query.responseFields.length, 2,
        reason:
            'After setting its responseFields to [\"hits\",\"page\"] getResponseFields should contain two elements.');
    expect(query.responseFields[0], 'hits',
        reason:
            'After setting its responseFields to [\"hits\",\"page\"] getResponseFields should contain \"hits\".');
    expect(query.responseFields[1], 'page',
        reason:
            'After setting its responseFields to [\"hits\",\"page\"] getResponseFields should contain \"page\".');
    queryStr = query.build();
    expected =
        'responseFields=${Uri.encodeQueryComponent('[\"hits\",\"page\"]')}';
    expect(queryStr.contains(expected), isTrue,
        reason:
            'The built query should contain "$expected", but contains $queryStr.');
  });

  test('ruleContexts', () async {
    final Query query = Query();
    expect(query.ruleContexts, isNull);
    query.ruleContexts = <String>['foo', 'bar'];
    expect(query.ruleContexts, orderedEquals(<String>['foo', 'bar']));
    expect(query['ruleContexts'], '[\"foo\",\"bar\"]');
    expect(Query.parse(query.build()).ruleContexts,
        orderedEquals(query.ruleContexts));
  });
}
