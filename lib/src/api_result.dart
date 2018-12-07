// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'package:algoliasearch/src/algolia_exception.dart';

/// Encapsulates the two possible outcomes of an API request: either a JSON
/// object (success), or an error (failure). One and only one is guaranteed to
/// be non-null.
class APIResult {
  /// Construct a new success result.
  ///
  /// The [content] returned.
  APIResult.success(this.content) : error = null;

  /// Construct a new failure result.
  ///
  /// The [error] that was encountered.
  APIResult.error(this.error) : content = null;

  /// The content returned (in case of success).
  final Map<String, dynamic> content;

  /// The error encountered (in case of failure).
  final AlgoliaException error;

  /// Test whether this is a success (true) or failure (false) result.
  bool get isSuccess => error == null;
}
