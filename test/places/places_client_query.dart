// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'package:algoliasearch/src/abstract_query.dart';
import 'package:algoliasearch/src/algolia_exception.dart';
import 'package:algoliasearch/src/places/places_client.dart';
import 'package:algoliasearch/src/places/places_query.dart';
import 'package:test/test.dart';

import '../keys.dart';

Future<void> main() async {
  const String objectIdRueRivoli = 'afd71bb8613f70ca495d8996923b5fd5';
  PlacesClient places;

  setUp(() {
    final Keys keys = Keys.places();
    places = PlacesClient(keys.applicationID, keys.apiKey);
  });

  test('search', () async {
    final PlacesQuery query = PlacesQuery()
      ..query = 'Paris'
      ..type = PlacesQueryType.city
      ..hitsPerPage = 10
      ..aroundLatLngViaIP = false
      ..aroundLatLng = const LatLng(32.7767, -96.7970) // Dallas, TX, USA
      ..language = 'en'
      ..countries = <String>['fr', 'us'];

    try {
      final Map<String, dynamic> content = await places.search(query);

      expect(content, isNotNull);
      expect(content['hits'], isNotNull);
      expect(content['hits'], isNotEmpty);
    } catch (e) {
      fail('$e');
    }
  });

  test('getByObjectIDValid', () async {
    final Map<String, dynamic> rivoli =
        await places.getByObjectID(objectIdRueRivoli);

    expect(rivoli, isNotNull);
    expect(rivoli['objectID'], objectIdRueRivoli);
  });

  test('getByObjectIDInvalid', () async {
    expect(() => places.getByObjectID('4242424242'),
        throwsA(const TypeMatcher<AlgoliaException>()));
  });
}
