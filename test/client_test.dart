// File created by
// Lung Razvan <long1eu>
// on 2018-12-05
import 'package:algoliasearch/src/abstract_client.dart';
import 'package:algoliasearch/src/client.dart';
import 'package:algoliasearch/src/index.dart';
import 'package:test/test.dart';

import 'keys.dart';

void main() async {
  Client client;

  setUp(() {
    final Keys keys = Keys();
    client = Client(keys.applicationID, keys.apiKey);
  });

  test('testIndexReuse', () {
    final Map<String, Index> indices = client.indices;
    const String indexName = 'name';

    // Ask for the same index twice and check that it is re-used.
    expect(indices.length, 0);
    final Index index1 = client.getIndex(indexName);
    expect(indices.length, 1);
    final Index index2 = client.getIndex(indexName);
    expect(index2, index1);
    expect(indices.length, 1);
  });

  test('testUniqueAgent', () {
    client
      ..addUserAgent(const LibraryVersion('foo', 'bar'))
      ..addUserAgent(const LibraryVersion('foo', 'bar'));

    final List<LibraryVersion> userAgents = client.userAgents;
    int found = 0;
    for (LibraryVersion userAgent in userAgents) {
      if (userAgent.name == 'foo') {
        found++;
      }
    }
    expect(found, 1, reason: 'There should be only one foo user agent.');
  });
}
