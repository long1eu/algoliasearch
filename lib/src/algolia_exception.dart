// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

/// Any error that was encountered during the processing of a request.
/// Could be server-side, network failure, or client-side.
class AlgoliaException implements Exception {
  AlgoliaException(this.message, [this.error, this.statusCode = 0]) : assert(error is! AlgoliaException);

  final String message;

  /// Only valid when the exception is an application-level error. Values are
  /// documented in the <a href="https://www.algolia.com/doc/rest">REST API</a>.
  ///
  /// Returns the HTTP status code, or 0 if not available.
  final int statusCode;
  final dynamic error;

  @override
  String toString() {
    final String data = 'AlgoliaException{message: $message,'
        ' statusCode: $statusCode, error: $error}';

    try {
      final StackTrace trace = error.stackTrace;
      return '$data\n$trace';
    } catch (e) {
      return data;
    }
  }
}
