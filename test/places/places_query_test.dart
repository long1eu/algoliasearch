// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'package:algoliasearch/src/abstract_query.dart';
import 'package:algoliasearch/src/places/places_query.dart';
import 'package:test/test.dart';

Future<void> main() async {
  test('hitsPerPage', () {
    final PlacesQuery query = PlacesQuery();
    expect(query.hitsPerPage, isNull);
    query.hitsPerPage = 50;

    expect(query.hitsPerPage, 50);
    expect(PlacesQuery.parse(query.build()).hitsPerPage, query.hitsPerPage);
  });

  test('query', () {
    final PlacesQuery query = PlacesQuery();
    expect(query.query, isNull);
    query.query = 'San Francisco';

    expect(query.query, 'San Francisco');
    expect(query['query'], 'San Francisco');
    expect(PlacesQuery.parse(query.build()).query, query.query);
  });

  test('highlightPreTag', () {
    final PlacesQuery query = PlacesQuery();
    expect(query.highlightPreTag, isNull);
    query.highlightPreTag = '<PRE[';

    expect(query.highlightPreTag, '<PRE[');
    expect(query['highlightPreTag'], '<PRE[');
    expect(
      PlacesQuery.parse(query.build()).highlightPreTag,
      query.highlightPreTag,
    );
  });

  test('highlightPostTag', () {
    final PlacesQuery query = PlacesQuery();
    expect(query.highlightPostTag, isNull);
    query.highlightPostTag = ']POST>';

    expect(query.highlightPostTag, ']POST>');
    expect(query['highlightPostTag'], ']POST>');
    expect(PlacesQuery.parse(query.build()).highlightPostTag,
        query.highlightPostTag);
  });

  test('aroundRadius', () {
    final PlacesQuery query = PlacesQuery();
    expect(query.aroundRadius, isNull);
    query.aroundRadius = 987;

    expect(query.aroundRadius, 987);
    expect(query['aroundRadius'], '987');
    expect(PlacesQuery.parse(query.build()).aroundRadius, query.aroundRadius);
  });

  test('aroundRadius_all', () {
    const int value = 3;
    final PlacesQuery query = PlacesQuery();
    expect(query.aroundRadius, isNull,
        reason: 'A new query should have a null aroundRadius.');

    query.aroundRadius = value;
    expect(query.aroundRadius, value,
        reason: 'After setting its aroundRadius to a given integer, we should '
            'return it from getAroundRadius.');

    String queryStr = query.build();
    expect(
      queryStr.allMatches('aroundRadius=$value'),
      isNotEmpty,
      reason: 'The built query should contain \'aroundRadius=\'$value.',
    );

    query.aroundRadius = PlacesQuery.kRadiusAll;
    expect(query.aroundRadius, PlacesQuery.kRadiusAll,
        reason: 'After setting it to RADIUS_ALL, a query should have this '
            'aroundRadius value.');

    queryStr = query.build();
    expect(
      queryStr.allMatches('aroundRadius=all'),
      isNotEmpty,
      reason: 'The built query should contain \'aroundRadius=all\', '
          'not _$queryStr .',
    );
    expect(PlacesQuery.parse(query.build()).aroundRadius, query.aroundRadius);
  });

  test('aroundLatLngViaIP', () {
    final PlacesQuery query = PlacesQuery();
    expect(query.aroundLatLngViaIP, isNull);
    query.aroundLatLngViaIP = true;

    expect(query.aroundLatLngViaIP, true);
    expect(query['aroundLatLngViaIP'], 'true');
    expect(PlacesQuery.parse(query.build()).aroundLatLngViaIP,
        query.aroundLatLngViaIP);
  });

  test('aroundLatLng', () {
    final PlacesQuery query = PlacesQuery();
    expect(query.aroundLatLng, isNull);
    query.aroundLatLng = const LatLng(89.76, -123.45);

    expect(query.aroundLatLng, const LatLng(89.76, -123.45));
    expect(query['aroundLatLng'], '89.76,-123.45');
    expect(PlacesQuery.parse(query.build()).aroundLatLng, query.aroundLatLng);
  });

  test('language', () {
    final PlacesQuery query = PlacesQuery();
    expect(query.query, isNull);
    query.language = 'en';

    expect(query.language, 'en');
    expect(query['language'], 'en');
    expect(PlacesQuery.parse(query.build()).query, query.query);
  });

  test('countries', () {
    final PlacesQuery query = PlacesQuery();
    expect(query.countries, isNull);
    query.countries = <String>['de', 'fr', 'us'];

    expect(query.countries, orderedEquals(<String>['de', 'fr', 'us']));
    expect(query['countries'], '["de","fr","us"]');
    expect(PlacesQuery.parse(query.build()).countries,
        orderedEquals(query.countries));
  });

  test('type', () {
    final PlacesQuery query = PlacesQuery();
    expect(query.type, isNull);

    query.type = PlacesQueryType.city;
    expect(query.type, PlacesQueryType.city);
    expect(query['type'], 'city');
    expect(PlacesQuery.parse(query.build()).type, query.type);

    query.type = PlacesQueryType.country;
    expect(query.type, PlacesQueryType.country);
    expect(query['type'], 'country');
    expect(PlacesQuery.parse(query.build()).type, query.type);

    query.type = PlacesQueryType.address;
    expect(query.type, PlacesQueryType.address);
    expect(query['type'], 'address');
    expect(PlacesQuery.parse(query.build()).type, query.type);

    query.type = PlacesQueryType.busStop;
    expect(query.type, PlacesQueryType.busStop);
    expect(query['type'], 'busStop');
    expect(PlacesQuery.parse(query.build()).type, query.type);

    query.type = PlacesQueryType.trainStation;
    expect(query.type, PlacesQueryType.trainStation);
    expect(query['type'], 'trainStation');
    expect(PlacesQuery.parse(query.build()).type, query.type);

    query.type = PlacesQueryType.townhall;
    expect(query.type, PlacesQueryType.townhall);
    expect(query['type'], 'townhall');
    expect(PlacesQuery.parse(query.build()).type, query.type);

    query.type = PlacesQueryType.airport;
    expect(query.type, PlacesQueryType.airport);
    expect(query['type'], 'airport');
    expect(PlacesQuery.parse(query.build()).type, query.type);

    query['type'] = 'invalid';
    expect(query.type, isNull);
  });
}
