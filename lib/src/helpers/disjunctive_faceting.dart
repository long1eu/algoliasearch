// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'package:algoliasearch/src/algolia_exception.dart';
import 'package:algoliasearch/src/query.dart';
import 'package:meta/meta.dart';

/// Disjunctive faceting helper.
class DisjunctiveFaceting {
  DisjunctiveFaceting({@required this.multipleQueriesAsync});

  /**
   * Run multiple queries. To be implemented by subclasses. The contract is the same as {@see Index#multipleQueriesAsync}.
   *
   * @param queries Queries to run.
   * @param completionHandler Completion handler to be notified of results.
   * @return A cancellable request.
   */
  final Future<Map<String, dynamic>> Function(List<Query> queries) multipleQueriesAsync;

  /**
   * Perform a search with disjunctive facets, generating as many queries as number of disjunctive facets.
   *
   * @param query             The query.
   * @param disjunctiveFacets List of disjunctive facets.
   * @param refinements       The current refinements, mapping facet names to a list of values.
   * @param completionHandler The listener that will be notified of the request's outcome.
   * @return A cancellable request.
   */
  Future<Map<String, dynamic>> searchDisjunctiveFacetingAsync<T extends List<String>>({@required Query query, @required List<String> disjunctiveFacets, @required Map<String, T> refinements}) async {
    final List<Query> queries = computeDisjunctiveFacetingQueries(query, disjunctiveFacets, refinements);

    final Map<String, dynamic> result = await multipleQueriesAsync(queries);

    return aggregateDisjunctiveFacetingResults(
      result,
      disjunctiveFacets,
      refinements,
    );
  }

  /**
   * Filter disjunctive refinements from generic refinements and a list of disjunctive facets.
   *
   * @param disjunctiveFacets the array of disjunctive facets
   * @param refinements       Map representing the current refinements
   * @return The disjunctive refinements
   */
  static Map<String, T> _filterDisjunctiveRefinements<T extends List<String>>(List<String> disjunctiveFacets, Map<String, T> refinements) {
    final Map<String, T> disjunctiveRefinements = <String, T>{};
    for (MapEntry<String, T> elt in refinements.entries) {
      if (disjunctiveFacets.contains(elt.key)) {
        disjunctiveRefinements[elt.key] = elt.value;
      }
    }
    return disjunctiveRefinements;
  }

  /**
   * Compute the queries to run to implement disjunctive faceting.
   *
   * @param query             The query.
   * @param disjunctiveFacets List of disjunctive facets.
   * @param refinements       The current refinements, mapping facet names to a list of values.
   * @return A list of queries suitable for {@link Index#multipleQueries}.
   */
  static List<Query> computeDisjunctiveFacetingQueries<T extends List<String>>(Query query, List<String> disjunctiveFacets, Map<String, T> refinements) {
    // Retain only refinements corresponding to the disjunctive facets.
    final Map<String, List<String>> disjunctiveRefinements = _filterDisjunctiveRefinements(disjunctiveFacets, refinements);

    // build queries
    final List<Query> queries = <Query>[];

    // first query: hits + regular facets

    List<dynamic> facetFilters = <dynamic>[];

    for (MapEntry<String, T> elt in refinements.entries) {
      final List<String> orFilters = <String>[];

      for (String val in elt.value) {
        // When already refined facet, or with existing refinements
        if (disjunctiveRefinements.containsKey(elt.key)) {
          orFilters.add(_formatFilter(elt, val));
        } else {
          facetFilters.add(_formatFilter(elt, val));
        }
      }
      // Add or
      if (disjunctiveRefinements.containsKey(elt.key)) {
        facetFilters.add(orFilters);
      }
    }

    //noinspection deprecation Deprecated for end-users
    queries.add(Query.copy(query)..facetFilters = facetFilters);
    // one query per disjunctive facet (use all refinements but the current
    // one + hitsPerPage=1 + single facet
    for (String disjunctiveFacet in disjunctiveFacets) {
      facetFilters = <dynamic>[];
      for (MapEntry<String, T> elt in refinements.entries) {
        if (disjunctiveFacet == elt.key) {
          continue;
        }
        final List<String> orFilters = <String>[];
        for (String val in elt.value) {
          if (disjunctiveRefinements.containsKey(elt.key)) {
            orFilters.add(_formatFilter(elt, val));
          } else {
            facetFilters.add(_formatFilter(elt, val));
          }
        }
        // Add or
        if (disjunctiveRefinements.containsKey(elt.key)) {
          facetFilters.add(orFilters);
        }
      }

      queries.add(Query()
        ..hitsPerPage = 0
        ..analytics = false
        ..attributesToRetrieve = <String>[]
        ..attributesToHighlight = <String>[]
        ..attributesToSnippet = <String>[]
        ..facets = <String>[disjunctiveFacet]
        ..facetFilters = facetFilters);
    }
    return queries;
  }

  static String _formatFilter<T extends List<String>>(MapEntry<String, T> refinement, String value) {
    return '${refinement.key}:$value';
  }

  /// Aggregate results from multiple queries into disjunctive faceting results.
  ///
  /// @param answers The answers from the multiple queries.
  /// @param disjunctiveFacets List of disjunctive facets.
  /// @param refinements Facet refinements.
  /// @return The aggregated results.
  @visibleForTesting
  static Map<String, dynamic> aggregateDisjunctiveFacetingResults<T extends List<String>>(
    Map<String, dynamic> answers,
    List<String> disjunctiveFacets,
    Map<String, T> refinements,
  ) {
    final Map<String, T> disjunctiveRefinements = _filterDisjunctiveRefinements(disjunctiveFacets, refinements);

    // aggregate answers
    // first answer stores the hits + regular facets
    try {
      bool nonExhaustiveFacetsCount = false;

      final List results = answers['results'];
      final Map aggregatedAnswer = results[0];

      final Map<String, dynamic> disjunctiveFacetsJSON = <String, dynamic>{};
      for (int i = 1; i < results.length; ++i) {
        final bool exhaustiveFacetsCount = results[i]['exhaustiveFacetsCount'];
        if (!exhaustiveFacetsCount) {
          nonExhaustiveFacetsCount = true;
        }
        final Map facets = results[i]['facets'];

        for (String key in facets.keys) {
          // Add the facet to the disjunctive facet hash
          disjunctiveFacetsJSON[key] = facets[key];
          // concatenate missing refinements
          if (!disjunctiveRefinements.containsKey(key)) {
            continue;
          }
          for (String refine in disjunctiveRefinements[key]) {
            if (disjunctiveFacetsJSON[key][refine] == null) {
              disjunctiveFacetsJSON[key][refine] = 0;
            }
          }
        }
      }
      aggregatedAnswer['disjunctiveFacets'] = disjunctiveFacetsJSON;
      if (nonExhaustiveFacetsCount) {
        aggregatedAnswer['exhaustiveFacetsCount'] = false;
      }
      return Map<String, dynamic>.from(aggregatedAnswer);
    } catch (e) {
      throw AlgoliaException('Failed to aggregate results', e);
    }
  }
}
