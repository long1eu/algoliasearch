// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'dart:convert';
import 'dart:io';

import 'package:algoliasearch/src/abstract_client.dart';
import 'package:algoliasearch/src/algolia_exception.dart';
import 'package:algoliasearch/src/client.dart';
import 'package:algoliasearch/src/index.dart';
import 'package:algoliasearch/src/query.dart';
import 'package:algoliasearch/src/request_options.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'keys.dart';

// ignore_for_file: lines_longer_than_80_chars

void main() {
  final String originalIndexName = 'àlgol?à-dart-${Uuid().v4()}';
  List<String> originalIds;
  List<Map<String, dynamic>> originalObjects;

  bool didInitIndices = false;

  Client client;
  Client clientWithLongApiKey;
  Index index;
  Index indexWithLongApiKey;
  String indexName;

  List<Map<String, dynamic>> objects;
  List<String> ids;

  setUp(() async {
    final Keys keys = Keys();
    client = Client(keys.applicationID, keys.apiKey);
    clientWithLongApiKey = Client(keys.applicationID, keys.longApiKey);

    if (!didInitIndices) {
      final Index originalIndex = client.getIndex(originalIndexName);
      await client.deleteIndex(name: originalIndexName);

      originalObjects = <Map<String, dynamic>>[
        <String, String>{
          'city': 'San Francisco',
          'state': 'CA',
        },
        <String, String>{
          'city': 'San José',
          'state': 'CA',
        },
      ];

      final Map<String, dynamic> task =
          await originalIndex.addObjects(originalObjects);
      final int taskID = task['taskID'];
      await originalIndex.waitTask(taskID);

      final List<String> objectIDs = List<String>.from(task['objectIDs']);
      originalIds = <String>[]..addAll(objectIDs);
      didInitIndices = true;
    }

    ids = List<String>.from(originalIds);
    objects = List<Map<String, dynamic>>.from(originalObjects);
    indexName = '$originalIndexName';
    index = client.getIndex(indexName);
    indexWithLongApiKey = clientWithLongApiKey.getIndex('some_index_name');
    print('Done setup.\n\n');
  });

  tearDown(() async {
    print('\n');
    final Map<String, dynamic> content =
        await client.deleteIndex(name: indexName);
    final int taskID = content['taskID'];
    await index.waitTask(taskID);
    print('Test done.');
  });

  test('search', () async {
    index = Client('1XFTRJUX0H', '357b5a200b006fb6aaf4dbce4b6f6bc1')
        .getIndex('dance_schools');
    final Map<String, dynamic> content = await index.search(Query.value('sam'));
    File('/Users/long1eu/IdeaProjects/algoliasearch/test.json')
        .writeAsStringSync(jsonEncode(content));
    expect(content['nbHits'], 1);
  });

  test('searchAsyncWithVeryLongApiKey', () async {
    try {
      await indexWithLongApiKey.search(Query.value('Francisco'));
      fail('This should fail.');
    } on AlgoliaException catch (e) {
      print(e);
      expect(e.statusCode, isNot(494));
    }
  });

  test('searchDisjunctiveFacetingAsync', () async {
    // Set index settings.
    final Map<String, dynamic> setSettingsResult = await index.setSettings(
      settings: <String, dynamic>{
        'attributesForFaceting': <String>['brand', 'category']
      },
      forwardToReplicas: false,
    );

    int taskId = setSettingsResult['taskID'];
    await index.waitTask(taskId);

    // Empty query
    // -----------
    // Not very useful, but we have to check this edge case.
    Map<String, dynamic> content = await index.searchDisjunctiveFacetingAsync(
      query: Query(),
      disjunctiveFacets: <String>[],
      refinements: <String, List<String>>{},
    );

    expect(content['nbHits'], objects.length,
        reason: 'Result length does not match nbHits');

    // 'Real' query
    // ------------
    // Create data set.
    objects = <Map<String, dynamic>>[
      <String, dynamic>{
        'name': 'iPhone 6',
        'brand': 'Apple',
        'category': 'device',
        'stars': 4,
      },
      <String, dynamic>{
        'name': 'iPhone 6 Plus',
        'brand': 'Apple',
        'category': 'device',
        'stars': 5,
      },
      <String, dynamic>{
        'name': 'iPhone cover',
        'brand': 'Apple',
        'category': 'accessory',
        'stars': 3,
      },
      <String, dynamic>{
        'name': 'Galaxy S5',
        'brand': 'Samsung',
        'category': 'device',
        'stars': 4,
      },
      <String, dynamic>{
        'name': 'Wonder Phone',
        'brand': 'Samsung',
        'category': 'device',
        'stars': 5,
      },
      <String, dynamic>{
        'name': 'Platinum Phone Cover',
        'brand': 'Samsung',
        'category': 'accessory',
        'stars': 2,
      },
      <String, dynamic>{
        'name': 'Lame Phone',
        'brand': 'Whatever',
        'category': 'device',
        'stars': 1,
      },
      <String, dynamic>{
        'name': 'Lame Phone cover',
        'brand': 'Whatever',
        'category': 'accessory',
        'stars': 1,
      },
      // Testing commas and quotes in facet values
      <String, dynamic>{
        'name': 'Symbols Phone',
        'brand': 'Commas\' voice, Ltd',
        'category': 'device',
        'stars': 2,
      },
    ];

    final Map<String, dynamic> task = await index.addObjects(objects);
    taskId = task['taskID'] as int;
    await index.waitTask(taskId);

    final Query query = Query.value('phone')
      ..facets = <String>['brand', 'category', 'stars'];

    final List<String> disjunctiveFacets = <String>['brand'];
    final Map<String, List<String>> refinements = <String, List<String>>{
      // disjunctive facet
      'brand': <String>['Apple', 'Samsung', 'Commas\' voice, Ltd'],
      // conjunctive facet
      'category': <String>['device']
    };

    content = await index.searchDisjunctiveFacetingAsync(
      query: query,
      disjunctiveFacets: disjunctiveFacets,
      refinements: refinements,
    );

    expect(content['nbHits'], 4);
    final Map disjunctiveFacetsResult = content['disjunctiveFacets'];
    expect(disjunctiveFacetsResult, isNotNull);
    final Map brandFacetCounts = disjunctiveFacetsResult['brand'];
    expect(brandFacetCounts, isNotNull);

    expect(brandFacetCounts['Apple'], 2);
    expect(brandFacetCounts['Samsung'], 1);
    expect(brandFacetCounts['Whatever'], 1);
    expect(brandFacetCounts['Commas\' voice, Ltd'], 1);
  }, timeout: const Timeout(Duration(minutes: 1)));

  test('disjunctiveFacetingAsync2', () async {
    // Set index settings.

    final Map<String, dynamic> setSettingsResult =
        await index.setSettings(settings: <String, dynamic>{
      'attributesForFaceting': <String>['city', 'stars', 'facilities']
    }, forwardToReplicas: false);

    final int taskId = setSettingsResult['taskID'];

    await index.waitTask(taskId);

    // Add objects.
    final Map<String, dynamic> addObjectsResult =
        await index.addObjects(<Map<String, dynamic>>[
      <String, dynamic>{
        'name': 'Hotel A',
        'stars': '*',
        'facilities': <String>['wifi', 'bath', 'spa'],
        'city': 'Paris'
      },
      <String, dynamic>{
        'name': 'Hotel B',
        'stars': '*',
        'facilities': <String>['wifi'],
        'city': 'Paris'
      },
      <String, dynamic>{
        'name': 'Hotel C',
        'stars': '**',
        'facilities': ['bath'],
        'city': 'San Fancisco'
      },
      <String, dynamic>{
        'name': 'Hotel D',
        'stars': '****',
        'facilities': <String>['spa'],
        'city': 'Paris'
      },
      <String, dynamic>{
        'name': 'Hotel E',
        'stars': '****',
        'facilities': <String>['spa'],
        'city': 'New York'
      }
    ]);

    final int addTaskId = addObjectsResult['taskID'];
    await index.waitTask(addTaskId);

    // Search.
    final Query query = Query.value('h')..facets = <String>['city'];
    final List<String> disjunctiveFacets = <String>['stars', 'facilities'];
    final Map<String, List<String>> refinements = <String, List<String>>{};

    Map<String, dynamic> content = await index.searchDisjunctiveFacetingAsync(
      query: query,
      disjunctiveFacets: disjunctiveFacets,
      refinements: refinements,
    );
    expect(content['nbHits'], 5);
    expect(content['facets'].length, 1);
    expect(content['disjunctiveFacets'].length, 2);

    refinements['stars'] = <String>['*'];
    content = await index.searchDisjunctiveFacetingAsync(
      query: query,
      disjunctiveFacets: disjunctiveFacets,
      refinements: refinements,
    );
    expect(content['nbHits'], 2);
    expect(content['facets'].length, 1);
    expect(content['disjunctiveFacets'].length, 2);
    expect(content['disjunctiveFacets']['stars']['*'], 2);
    expect(content['disjunctiveFacets']['stars']['**'], 1);
    expect(content['disjunctiveFacets']['stars']['****'], 2);

    refinements['city'] = <String>['Paris'];
    content = await index.searchDisjunctiveFacetingAsync(
      query: query,
      disjunctiveFacets: disjunctiveFacets,
      refinements: refinements,
    );
    expect(content['nbHits'], 2);
    expect(content['facets'].length, 1);
    expect(content['disjunctiveFacets'].length, 2);
    expect(content['disjunctiveFacets']['stars']['*'], 2);
    expect(content['disjunctiveFacets']['stars']['****'], 1);

    refinements['stars'] = <String>['*', '****'];
    content = await index.searchDisjunctiveFacetingAsync(
      query: query,
      disjunctiveFacets: disjunctiveFacets,
      refinements: refinements,
    );
    expect(content['nbHits'], 3);
    expect(content['facets'].length, 1);
    expect(content['disjunctiveFacets'].length, 2);
    expect(content['disjunctiveFacets']['stars']['*'], 2);
    expect(content['disjunctiveFacets']['stars']['****'], 1);
  });

  test('addObjectAsync', () async {
    final Map<String, dynamic> content =
        await index.addObject(<String, String>{'city': 'New York'});
    expect(content['objectID'], isNotNull,
        reason: 'Result has no objectId: $content');
  });

  test('addObjectWithObjectIDAsync', () async {
    final Map<String, dynamic> content = await index
        .addObject(<String, String>{'city': 'New York'}, objectId: 'a1b2c3');
    expect(content['objectID'], 'a1b2c3',
        reason: 'Object has unexpected objectId');
  });

  test('addObjectsAsync', () async {
    final Map<String, dynamic> content =
        await index.addObjects(<Map<String, dynamic>>[
      <String, String>{'city': 'New York'},
      <String, String>{'city': 'Paris'},
    ]);

    expect(content['objectIDs'].length, 2,
        reason: 'Objects have unexpected objectId count');
  });

  test('saveObjectAsync', () async {
    final Map<String, dynamic> content = await index.saveObject(
        object: <String, dynamic>{'city': 'New York'}, objectID: 'a1b2c3');
    expect(content['objectID'], 'a1b2c3',
        reason: 'Object has unexpected objectId');
  });

  test('saveObjectsAsync', () async {
    final Map<String, dynamic> content =
        await index.saveObjects(<Map<String, dynamic>>[
      <String, dynamic>{
        'city': 'New York',
        'objectID': 123,
      },
      <String, dynamic>{
        'city': 'Paris',
        'objectID': 456,
      },
    ]);

    expect(content['objectIDs'].length, 2,
        reason: 'Objects have unexpected objectId count');
    expect(content['objectIDs'][0], '123',
        reason: 'Object has unexpected objectId');
    expect(content['objectIDs'][1], '456',
        reason: 'Object has unexpected objectId');
  });

  test('getObjectAsync', () async {
    final Map<String, dynamic> content = await index.getObject(ids.first);
    expect(content['objectID'], ids.first,
        reason: 'Object has unexpected objectId');
    expect(content['city'], 'San Francisco',
        reason: 'Object has unexpected \'city\' attribute');
  });

  test('getObjectWithAttributesToRetrieveAsync', () async {
    final Map<String, dynamic> content = await index.getObject(
      ids.first,
      attributesToRetrieve: <String>['objectID', 'state'],
    );

    expect(content['objectID'], ids.first,
        reason: 'Object has unexpected objectId');
    expect(content.containsKey('state'), isTrue,
        reason: 'Object is missing expected \'state\' attribute');
    expect(content.containsKey('city'), isFalse,
        reason: 'Object has unexpected \'city\' attribute');
  });

  test('getObjectsAsync', () async {
    final Map<String, dynamic> content = await index.getObjects(ids);

    final List res = content['results'];
    expect(res, isNotNull);
    expect(res[0]['objectID'], ids[0],
        reason: 'Object has unexpected objectId');
    expect(res[1]['objectID'], ids[1],
        reason: 'Object has unexpected objectId');
  });

  test('getObjectsWithAttributesToRetrieveAsync', () async {
    final List<String> attributesToRetrieve = <String>['objectID'];

    final Map<String, dynamic> content =
        await index.getObjects(ids, attributesToRetrieve: attributesToRetrieve);
    final List res = content['results'];
    expect(res, isNotNull);
    expect(res[0]['objectID'], ids[0],
        reason: 'Object has unexpected objectId');
    expect(res[1].containsKey('city'), isFalse,
        reason: 'Object has unexpected \'city\' attribute');
  });

  test('waitTaskAsync', () async {
    Map<String, dynamic> content =
        await index.addObject(<String, dynamic>{'city': 'New York'});
    final int taskId = content['taskID'];
    content = await index.waitTask(taskId);
    expect('published', content['status']);
  });

  test('hostSwitch', () async {
    // Given first host as an unreachable domain
    final List<String> hostsArray = client.readHosts;
    hostsArray[0] =
        'thissentenceshouldbeuniqueenoughtoguaranteeinexistentdomain.com';
    client.readHosts = hostsArray;

    // Expect a switch to the next URL and successful search
    final Map<String, dynamic> content =
        await index.search(Query.value('Francisco'));
    expect(content['nbHits'], 1);
  });

  test('SNI', () async {
    // Given all hosts using SNI
    final String appId = client.applicationID;
    client.readHosts = <String>[
      '$appId-1.algolianet.com',
      '$appId-2.algolianet.com',
      '$appId-3.algolianet.com',
      '$appId-3.algolianet.com',
    ];

    // Expect correct certificate handling and successful search
    final Map<String, dynamic> content =
        await index.search(Query.value('Francisco'));
    expect(content['nbHits'], 1);
  });

  test('keepAlive', () async {
    const int nbTimes = 10;

    // Given all hosts being the same one
    final String appId = client.applicationID;
    client.readHosts = <String>[
      '$appId-1.algolianet.com',
      '$appId-1.algolianet.com',
      '$appId-1.algolianet.com',
      '$appId-1.algolianet.com',
    ];

    //And an index that does not cache search queries
    index.disableSearchCache();

    // Expect first successful search
    final List<DateTime> startEndTimeArray = <DateTime>[]..length = 2;
    startEndTimeArray[0] = DateTime.now();
    Map<String, dynamic> content = await index.search(Query.value('Francisco'));
    expect(content['nbHits'], 1);
    startEndTimeArray[1] = DateTime.now();

    final Duration firstDurationNanos =
        startEndTimeArray[1].difference(startEndTimeArray[0]);
    for (int i = 0; i < nbTimes; i++) {
      startEndTimeArray[0] = DateTime.now();
      final int finalIter = i;
      content = await index.search(Query.value('Francisco'));

      startEndTimeArray[1] = DateTime.now();
      final Duration iterDiff =
          startEndTimeArray[1].difference(startEndTimeArray[0]);
      final String iterString =
          'iteration $finalIter: $iterDiff < $firstDurationNanos';

      // And successful fastest subsequent calls
      expect(content['nbHits'], 1);
      expect(
          startEndTimeArray[1].difference(startEndTimeArray[0]) <
              firstDurationNanos,
          isTrue,
          reason:
              'Subsequent calls should be fastest than first ($iterString)');
    }
  });

  Future<void> addDummyObjects(int objectCount) async {
    // Construct an array of dummy objects.
    objects = <Map<String, dynamic>>[];
    for (int i = 0; i < objectCount; ++i) {
      objects.add(<String, dynamic>{'dummy': i});
    }

    // Add objects.
    final Map<String, dynamic> content = await index.addObjects(objects);
    final int taskId = content['taskID'];
    await index.waitTask(taskId);
  }

  test('browseAsync', () async {
    await addDummyObjects(1500);
    final Query query = Query()..hitsPerPage = 1000;
    Map<String, dynamic> content = await index.browse(query);

    String cursor = content['cursor'];
    expect(cursor, isNotNull);

    content = await index.browseFrom(cursor);
    cursor = content['cursor'] as String;
    expect(cursor, isNull);
  });

  test('clearIndexAsync', () async {
    Map<String, dynamic> content = await index.clearIndex();
    await index.waitTask(content['taskID'] as int);
    content = await index.browse(Query());
    expect(content['nbHits'], 0);
  });

  test('deleteByQueryAsync', () async {
    await addDummyObjects(3000);

    final Query query = Query()..filters = 'dummy < 1500';

    await index.deleteBy(query);
    final Map<String, dynamic> content = await index.browse(query);
    // There should not remain any object matching the query.
    expect(content['hits'], isNotNull);
    expect(content['hits'], isEmpty);
    expect(content['cursor'], isNull);
  });

  test('deleteByAsync', () async {
    await addDummyObjects(3000);

    final Query query = Query()..filters = 'dummy < 1500';

    Map<String, dynamic> content = await index.deleteBy(query);

    final int taskID = content['taskID'];
    await index.waitTask(taskID);

    content = await index.browse(query);
    // There should not remain any object matching the query.
    expect(content['hits'], isNotNull);
    expect(content['hits'], isNotEmpty);
    expect(content['cursor'], isNull);
  });

  test('error404', () async {
    final Index unknownIndex = client.getIndex('doesnotexist');

    try {
      await unknownIndex.search(Query());
    } on AlgoliaException catch (error) {
      expect(error, isNotNull);
      expect(error.statusCode, 404);
      expect(error.message, isNotNull);
    }
  });

  // Verifies the number of requests fired by two search queries
  Future<void> verifySearchTwiceCalls(int nbTimes,
      [int waitBetweenSeconds = 0]) async {
    // Given a index, using a client that returns some json on search
    final Client mockClient = ClientMock();
    index.client = mockClient;

    when(mockClient.postRequestRaw(
      url: argThat(const TypeMatcher<String>(), named: 'url'),
      body: argThat(const TypeMatcher<Map<String, dynamic>>(), named: 'body'),
      readOperation: argThat(const TypeMatcher<bool>(), named: 'readOperation'),
      requestOptions: argThat(isNull, named: 'requestOptions'),
    )).thenAnswer((_) => Future<List<int>>.value(utf8.encode('{"foo":42}')));

    // When searching twice separated by waitBetweenSeconds, fires nbTimes requests
    final Query query = Query.value('San');
    await index.search(query);

    if (waitBetweenSeconds > 0) {
      await Future<void>.delayed(Duration(seconds: waitBetweenSeconds));
    }

    await index.search(query);

    verify(mockClient.postRequestRaw(
      url: argThat(const TypeMatcher<String>(), named: 'url'),
      body: argThat(const TypeMatcher<Map<String, dynamic>>(), named: 'body'),
      readOperation: argThat(const TypeMatcher<bool>(), named: 'readOperation'),
      requestOptions: argThat(isNull, named: 'requestOptions'),
    )).called(nbTimes);
  }

  test('cacheUseIfEnabled', () async {
    index.enableSearchCache();
    await verifySearchTwiceCalls(1);
  });

  test('cacheDontUseByDefault', () async {
    await verifySearchTwiceCalls(2);
  });

  test('cacheDontUseIfDisabled', () async {
    index.disableSearchCache();
    await verifySearchTwiceCalls(2);
  });

  test('cacheTimeout', () async {
    index.enableSearchCache(timeoutInSeconds: const Duration(seconds: 1));
    await verifySearchTwiceCalls(2, 2);
  });

  test('multipleQueries', () async {
    final List<Query> queries = <Query>[
      Query.value('francisco')..hitsPerPage = 1,
      Query.value('jose')
    ];
    final Map<String, dynamic> content = await index.multipleQueries(
        queries: queries,
        strategy: MultipleQueriesStrategy.stopIfEnoughMatches);
    print(jsonEncode(content));

    final List results = content['results'];
    expect(results, isNotNull);
    expect(2, results.length);

    final Map results1 = results[0];
    expect(results1, isNotNull);
    expect(results1['nbHits'], 1);

    final Map results2 = results[1];
    expect(results2, isNotNull);
    expect(results2['processed'] ?? true, isFalse);
    expect(results2['nbHits'], 0);
  });

  test('userAgent', () async {
    // Test the default value.
    String userAgent = client.userAgentRaw;
    print(userAgent);
    expect(
        RegExp('^Algolia for Dart \\([0-9.]+\\); Dart \\(([0-9.]+.+?)\\)\$')
            .hasMatch(userAgent),
        isTrue);

    // Manipulate the list.
    expect(client.hasUserAgent(const LibraryVersion('toto', '6.6.6')), isFalse);
    client.addUserAgent(const LibraryVersion('toto', '6.6.6'));
    expect(client.hasUserAgent(const LibraryVersion('toto', '6.6.6')), isTrue);
    userAgent = client.userAgentRaw;
    expect(RegExp('^.*; toto \\(6.6.6\\)\$').hasMatch(userAgent), isTrue);
  });

  test('getObjectAttributes', () async {
    for (String id in ids) {
      Map<String, dynamic> object = await index.getObject(id);
      // 2 attributes + `objectID`
      expect(object.keys.length, 3,
          reason: 'The retrieved object should have 3 attributes.');
      object =
          await index.getObject(id, attributesToRetrieve: <String>['city']);
      // 1 attribute + `objectID`
      expect(object.keys.length, 2,
          reason: 'The retrieved object should have 2 attributes.');
      expect(object['objectID'], isNotNull,
          reason: 'The retrieved object should have an `objectID` attribute.');
      expect(object['city'], isNotNull,
          reason: 'The retrieved object should have a `city` attribute.');
    }
  });

  test('getObjectsAttributes', () async {
    Map<String, dynamic> contents = await index.getObjects(ids);
    List results = contents['results'];
    for (int i = 0; i < results.length; i++) {
      final Map object = results[i];
      // 2 attributes + `objectID`
      expect(object.keys.length, 3,
          reason: 'The retrieved object should have 3 attributes.');
    }

    contents =
        await index.getObjects(ids, attributesToRetrieve: <String>['city']);
    results = contents['results'] as List;
    for (int i = 0; i < results.length; i++) {
      final Map object = results[i];
      // 1 attribute + `objectID`
      expect(object.keys.length, 2,
          reason: 'The retrieved object should have 2 attributes.');
      expect(object['objectID'], isNotNull,
          reason: 'The retrieved object should have an `objectID` attribute.');
      expect(object['city'], isNotNull,
          reason: 'The retrieved object should have a `city` attribute.');
    }
  });

  test('partialUpdateObject', () async {
    final Map<String, String> partialObject = <String, String>{'city': 'Paris'};
    Map<String, dynamic> content = await index.partialUpdateObject(
        partialObject: partialObject, objectID: ids.first);

    final int taskID = content['taskID'];
    await index.waitTask(taskID);

    content = await index.getObject(ids.first);
    expect(content, isNotNull);
    expect(content['objectID'], ids.first);
  });

  test('partialUpdateObjectNoCreate', () async {
    const String objectID = 'unknown';
    final Map<String, String> partialObject = <String, String>{'city': 'Paris'};

    // Partial update on a nonexistent object with `createIfNotExists=false` should not create the object.
    Map<String, dynamic> content = await index.partialUpdateObject(
      partialObject: partialObject,
      objectID: objectID,
      createIfNotExists: false,
    );

    int taskID = content['taskID'];
    await index.waitTask(taskID);

    try {
      await index.getObject(objectID);
      fail('This should fail.');
    } on AlgoliaException catch (e) {
      expect(e, isNotNull);
      expect(e.statusCode, 404);
    }

    content = await index.partialUpdateObject(
      partialObject: partialObject,
      objectID: objectID,
      createIfNotExists: true,
    );
    taskID = content['taskID'] as int;
    await index.waitTask(taskID);

    content = await index.getObject(objectID);
    expect(content, isNotNull);
    expect(content['objectID'], objectID);
  }, timeout: const Timeout(Duration(minutes: 1)));

  test('partialUpdateObjects', () async {
    final List<Map<String, String>> partialObjects = <Map<String, String>>[
      <String, String>{'objectID': ids[0], 'city': 'Paris'},
      <String, String>{'objectID': ids[1], 'city': 'Berlin'}
    ];

    Map<String, dynamic> content = await index.partialUpdateObjects(
        objects: partialObjects, createIfNotExists: false);

    final int taskID = content['taskID'];
    await index.waitTask(taskID);
    content = await index.getObjects(ids);

    expect(content, isNotNull);
    final List results = content['results'];
    expect(results, isNotNull);
    expect(results.length, 2);
    for (int i = 0; i < partialObjects.length; ++i) {
      final Map result = results[i];
      expect(result['objectID'], ids[i]);
      expect(result['city'], partialObjects[i]['city']);
    }
  });

  test('partialUpdateObjectsNoCreate', () async {
    final List<String> newIds = <String>['unknown', 'none'];

    final List<Map<String, String>> partialObjects = <Map<String, String>>[
      <String, String>{'objectID': newIds[0], 'city': 'Paris'},
      <String, String>{'objectID': newIds[1], 'city': 'Berlin'},
    ];

    Map<String, dynamic> content = await index.partialUpdateObjects(
        objects: partialObjects, createIfNotExists: false);

    int taskID = content['taskID'];
    await index.waitTask(taskID);
    await index.getObjects(newIds);

    // NOTE: A multiple get objects doesn't return an error for nonexistent objects,
    // but simply returns `null` for the missing objects.
    expect(content, isNotNull);

    List results = content['results'];
    expect(results, isNotNull);
    expect(results.length, 2);
    expect(results[0], 'null');
    expect(results[1], 'null');

    content = await index.partialUpdateObjects(
        objects: partialObjects, createIfNotExists: false);
    taskID = content['taskID'] as int;
    await index.waitTask(taskID);
    content = await index.getObjects(newIds);
    expect(content, isNotNull);

    results = content['results'] as List;
    expect(results, isNotNull);
    expect(results.length, 2);
    for (int i = 0; i < partialObjects.length; ++i) {
      expect(results[i]['city'], partialObjects[i]['city']);
    }
  });

  String getRandomString() => Uuid().v4().toString();

  test('retryUsingHostStatus', () async {
    List<String> hostsArray = client.readHosts;
    String randomHostName = '${getRandomString()}-dsn.algolia.biz';
    final String nextHostName = hostsArray[1];

    // Given a first host that timeouts, randomized to ensure no system caching
    hostsArray[0] = randomHostName;
    client.readHosts = hostsArray;

    // Expect reachable hosts before any connection
    expect(client.isUpOrCouldBeRetried(randomHostName), isTrue,
        reason: 'Hosts should be considered up before first connection.');
    expect(client.isUpOrCouldBeRetried(nextHostName), isTrue,
        reason: 'Hosts should be considered up before first connection.');

    // Expect success after a failing host
    Map<String, dynamic> content = await index.search(Query.value('Francisco'));
    expect(content['nbHits'], 1);

    // Expect down host after failed connection, up host after successful connection
    expect(client.isUpOrCouldBeRetried(randomHostName), isFalse,
        reason: 'A host that has failed recently should be considered down.');
    expect(client.isUpOrCouldBeRetried(nextHostName), isTrue,
        reason: 'A host that has succeeded recently should be considered up.');

    hostsArray = client.readHosts;

    randomHostName = '${getRandomString()}-dsn.algolia.biz';

    // Given a short host delay and a first host that timeouts
    const int delay = 100;
    client.hostDownDelay = const Duration(milliseconds: delay);
    hostsArray[0] = randomHostName;
    client.readHosts = hostsArray;

    // Expect success after a failing host
    content = await index.search(Query.value('Francisco'));
    expect(content['nbHits'], 1);

    // Expect host to be up again after the delay has passed
    await Future<void>.delayed(const Duration(milliseconds: delay));

    expect(client.isUpOrCouldBeRetried(randomHostName), isTrue,
        reason:
            'A host that has failed should be considered up once the delay is over.');
  });

  test('requestOptionsHeaders', () async {
    try {
      // Override the API key in the request options and check that we get an authentication error.
      await client.listIndexes(
          requestOptions: RequestOptions()
            ..setHeader('X-Algolia-API-Key', 'ThisAPIKeyIsNotValid'));
    } on AlgoliaException catch (e) {
      expect(e, isNotNull);
      expect(e.statusCode, 403);
    }
  });

  test('requestOptionsUrlParameters', () async {
    // Listing indices without options should return at least one item.
    Map<String, dynamic> content = await client.listIndexes();
    expect(content, isNotNull);
    expect(content['items'], isNotNull);
    expect(content['items'], isNotEmpty);

    // Listing indices with a `page` URL parameter very high should return no items.
    content = await client.listIndexes(
        requestOptions: RequestOptions()..setUrlParameter('page', '666'));

    expect(content, isNotNull);
    expect(content['items'], isNotNull);
    expect(content['items'], isEmpty);
  });

  test('searchWithClickTrackingAsync', () async {
    final DateTime begin = DateTime.now();
    final Query query = Query.value('Francisco')..clickAnalytics = true;

    final Map<String, dynamic> content = await index.search(query);
    expect(content['queryID'], isNotNull);

    final Duration elapsedMillis = DateTime.now().difference(begin);
    const Duration waitTimeoutMillis = Duration(seconds: 30);
    expect(elapsedMillis <= waitTimeoutMillis, isTrue,
        reason:
            'The test took longer than given timeout ($elapsedMillis > $waitTimeoutMillis).');
  });
}

class ClientMock extends Mock implements Client {}
