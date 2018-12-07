// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'package:algoliasearch/src/index.dart';
import 'package:algoliasearch/src/query.dart';

/// A search query targeting a specific index.
class IndexQuery {
  IndexQuery({Index index, String indexName, this.query})
      : indexName = indexName ?? index.rawIndexName;

  final String indexName;
  final Query query;
}
