// File created by
// Lung Razvan <long1eu>
// on 2018-12-05
import 'package:algoliasearch/src/helpers/disjunctive_faceting.dart';
import 'package:test/test.dart';

// ignore_for_file: lines_longer_than_80_chars
void main() {
  test('aggregateResultsPropagatesNonExhaustiveCount', () {
    final List<String> disjunctiveFacets = <String>[];
    final Map<String, List<String>> refinements = <String, List<String>>{};

    //
    Map<String, dynamic> answers = <String, dynamic>{
      'results': <Map<String, dynamic>>[
        <String, dynamic>{
          'facets': <String, dynamic>{},
          'exhaustiveFacetsCount': true,
        },
        <String, dynamic>{
          'facets': <String, dynamic>{},
          'exhaustiveFacetsCount': true,
        },
      ]
    };
    Map<String, dynamic> result = DisjunctiveFaceting.aggregateDisjunctiveFacetingResults(answers, disjunctiveFacets, refinements);
    expect(result['exhaustiveFacetsCount'], isTrue, reason: 'If all results have exhaustive counts, the aggregated one should too.');

    //
    answers = <String, dynamic>{
      'results': <Map<String, dynamic>>[
        <String, dynamic>{
          'facets': <String, dynamic>{},
          'exhaustiveFacetsCount': false,
        },
        <String, dynamic>{
          'facets': <String, dynamic>{},
          'exhaustiveFacetsCount': true,
        },
      ],
    };
    result = DisjunctiveFaceting.aggregateDisjunctiveFacetingResults(answers, disjunctiveFacets, refinements);
    expect(result['exhaustiveFacetsCount'], isFalse, reason: 'If some results have non-exhaustive counts, neither should the aggregated one.');

    //
    answers = <String, dynamic>{
      'results': <Map<String, dynamic>>[
        <String, dynamic>{
          'facets': <String, dynamic>{},
          'exhaustiveFacetsCount': true,
        },
        <String, dynamic>{
          'facets': <String, dynamic>{},
          'exhaustiveFacetsCount': false,
        },
      ],
    };
    result = DisjunctiveFaceting.aggregateDisjunctiveFacetingResults(answers, disjunctiveFacets, refinements);
    expect(result['exhaustiveFacetsCount'], isFalse, reason: 'If some results have non-exhaustive counts, neither should the aggregated one.');

    //
    answers = <String, dynamic>{
      'results': <Map<String, dynamic>>[
        <String, dynamic>{
          'facets': <String, dynamic>{},
          'exhaustiveFacetsCount': false,
        },
        <String, dynamic>{
          'facets': <String, dynamic>{},
          'exhaustiveFacetsCount': false,
        },
      ],
    };
    result = DisjunctiveFaceting.aggregateDisjunctiveFacetingResults(answers, disjunctiveFacets, refinements);
    expect(result['exhaustiveFacetsCount'], isFalse, reason: 'If no results have exhaustive counts, neither should the aggregated one.');
  });
}
