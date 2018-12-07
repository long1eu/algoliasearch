// File created by
// Lung Razvan <long1eu>
// on 2018-12-04

import 'package:algoliasearch/src/query.dart';
import 'package:algoliasearch/src/request_options.dart';
import 'package:meta/meta.dart';

/// A searchable source of data
abstract class Searchable {
  /// Search inside this index (asynchronously).
  ///
  /// [query] Search parameters. May be null to use an empty query.
  /// @param requestOptions    Request-specific options.
  /// @param completionHandler The listener that will be notified of the
  /// request's outcome.
  /// @return A cancellable request.
  Future<Map<String, dynamic>> search(Query query, {RequestOptions requestOptions});

  /// Perform a search with disjunctive facets, generating as many queries as
  /// number of disjunctive facets (helper).
  ///
  /// @param query             The query.
  /// @param disjunctiveFacets List of disjunctive facets.
  /// @param refinements       The current refinements, mapping facet names to a
  /// list of values.
  /// @param requestOptions    Request-specific options.
  /// @param completionHandler The listener that will be notified of the
  /// request's outcome.
  /// @return A cancellable request.
  Future<Map<String, dynamic>> searchDisjunctiveFacetingAsync(
      {@required Query query, @required List<String> disjunctiveFacets, @required Map<String, List<String>> refinements, final RequestOptions requestOptions}) {
    throw StateError('make sure to override searchDisjunctiveFacetingAsync '
        'for custom backend');
  }

  /// Search for some text in a facet values, optionally restricting the
  /// returned values to those contained in objects matching other (regular)
  /// search criteria.
  ///
  /// @param facetName      The name of the facet to search. It must have been
  /// declared in the index's `attributesForFaceting` setting with the
  /// `searchable()` modifier.
  /// @param facetText      The text to search for in the facet's values.
  /// @param query          An optional query to take extra search parameters
  /// into account. There parameters apply to index objects like in a regular
  /// search query. Only facet values contained in the matched objects will be
  /// returned
  /// @param requestOptions Request-specific options.
  /// @param handler        A Completion handler that will be notified of the
  /// request's outcome.
  /// @return A cancellable request.
  Future<Map<String, dynamic>> searchForFacetValuesAsync({
    @required String facetName,
    @required String facetText,
    @required Query query,
    RequestOptions requestOptions,
  }) {
    throw StateError('make sure to override searchForFacetValuesAsync for custom backend');
  }

  /// If you override this please be sure it returns a unique string per
  /// instance
  @override
  String toString() {
    return super.toString();
  }
}
