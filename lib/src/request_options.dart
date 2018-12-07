// File created by
// Lung Razvan <long1eu>
// on 2018-12-04

import 'client.dart';

/// Per-request options.
/// This class allows specifying options at the request level, overriding
/// default options at the [Client] level.
///
/// NOTE: These are reserved for advanced use cases. In most situations, they
/// shouldn't be needed.
class RequestOptions {
  RequestOptions() : headers = <String, String>{};

  /// HTTP headers, as untyped values.
  final Map<String, String> headers;

  /// URL parameters, as untyped values.
  ///
  /// These will go into the query string part of the URL (after the question
  /// mark).
  Map<String, String> urlParameters = <String, String>{};

  /// Set a HTTP header (untyped version).
  /// Whenever possible, you should use a typed accessor.
  ///
  /// [name] of the header. [value] of the header, or `null` to remove the
  /// header.
  void setHeader(String name, String value) {
    if (value == null) {
      headers.remove(name);
    } else {
      headers[name] = value;
    }
  }

  /// Get the value of a HTTP header.
  ///
  /// [name] of the header.
  /// Returns the value of the header, or `null` if it does not exist.
  String getHeader(String name) => headers[name];

  /// Set a URL parameter (untyped version).
  /// Whenever possible, you should use a typed accessor.
  ///
  /// [name] of the parameter. [value] of the parameter, or `null` to remove it.
  void setUrlParameter(String name, String value) {
    if (value == null) {
      urlParameters.remove(name);
    } else {
      urlParameters[name] = value;
    }
  }

  /// Get the value of a URL parameter.
  ///
  /// [name] of the parameter.
  /// Returns the value of the parameter, or `null` if it does not exist.
  String getUrlParameter(String name) => urlParameters[name];

  @override
  String toString() => '$runtimeType{headers: $headers}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestOptions &&
          runtimeType == other.runtimeType &&
          headers == other.headers;

  @override
  int get hashCode => headers.hashCode;
}
