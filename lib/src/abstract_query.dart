// File created by
// Lung Razvan <long1eu>
// on 2018-12-04

import 'dart:collection';
import 'dart:convert';

/// An abstract search query.
abstract class AbstractQuery {
  AbstractQuery({AbstractQuery other})
      : parameters = other == null
            ? SplayTreeMap<String, String>()
            : SplayTreeMap<String, String>.from(other.parameters);

  /// Query parameters, as an untyped key-value array.
  final Map<String, String> parameters;

  static String buildParams(Map<String, String> parameters) {
    final StringBuffer stringBuilder = StringBuffer();

    for (MapEntry<String, String> entry in parameters.entries) {
      final String key = entry.key;
      if (stringBuilder.length > 0) {
        stringBuilder.write('&');
      }
      stringBuilder.write(_urlEncode(key));
      final String value = entry.value;
      if (value != null) {
        stringBuilder..write('=')..write(_urlEncode(value));
      }
    }

    return stringBuilder.toString();
  }

  /// Build a query string from a map of URL parameters.
  /// Returns a string suitable for use inside the query part of a URL (i.e.
  /// after the question mark).
  String build() => buildParams(parameters);

  static String _urlEncode(String value) {
    // NOTE: We prefer to have space encoded as `%20` instead of `+`, so we
    // patch `URLEncoder`'s behaviour.
    //
    // This works because `+` itself is percent-escaped (into `%2B`).
    return Uri.encodeQueryComponent(value).replaceAll('+', '%20');
  }

  static bool parseBool(String value) {
    if (value == null) {
      return null;
    }

    if (value.trim().toLowerCase() == 'true') {
      return true;
    }
    final int intValue = parseInt(value);
    return intValue != null && intValue != 0;
  }

  static int parseInt(String value) =>
      value == null ? null : int.tryParse(value.trim());

  static String buildJSONArray(List<String> values) => jsonEncode(values);

  static List<String> parseArray(String string) {
    if (string == null) {
      return null;
    }

    // First try to parse JSON notation.
    try {
      final List<String> result = jsonDecode(string).cast<String>();
      return result;
    }
    // Otherwise parse as a comma-separated list.
    catch (e) {
      return string.split(',');
    }
  }

  static String buildCommaArray(List<String> values) => values.join(',');

  static List<String> parseCommaArray(String string) =>
      string == null ? null : string.split(',');

  /// Parse a URL query parameter string and store the resulting parameters into
  /// this query.
  ///
  /// [queryParameters] URL query parameter string.
  void parseFrom(String queryParameters) {
    final List<String> parameters = queryParameters.split('&');
    for (String parameter in parameters) {
      final List<String> components = parameter.split('=');
      if (components.isEmpty || components.length > 2) {
        continue; // ignore invalid values
      }

      final String name = Uri.decodeQueryComponent(components[0]);
      final String value = components.length >= 2
          ? Uri.decodeQueryComponent(components[1])
          : null;

      this[name] = value;
    }
  }

  /// Set a parameter in an untyped fashion.
  /// This low-level accessor is intended to access parameters that this client
  /// does not yet support.
  /// [name] The parameter's name.
  /// [value] The parameter's value, or null to remove it.
  ///
  /// It will first be converted to a String by the `toString()` method.
  void operator []=(String name, Object value) {
    if (value == null) {
      parameters.remove(name);
    } else {
      parameters[name] = value.toString();
    }
  }

  /// Get a parameter in an untyped fashion.
  ///
  /// [name] the parameter's name.
  /// Returns the parameter's value, or null if a parameter with the specified
  /// name does not exist.
  String operator [](String name) => parameters[name];

  /// Obtain a debug representation of this query.
  ///
  /// To get the raw query URL part, please see [build].
  /// Returns a debug representation of this query.
  @override
  String toString() => '$runtimeType{$build()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AbstractQuery &&
          runtimeType == other.runtimeType &&
          parameters == other.parameters;

  @override
  int get hashCode => parameters.hashCode;
}

/// A pair of (latitude, longitude).
/// Used in geo-search.
class LatLng {
  const LatLng(this.lat, this.lng);

  /// Parse a [LatLng] from its string representation.
  ///
  /// [value] is a string representation of a (latitude, longitude) pair, in the
  /// format `12.345,67.890` (number of digits may vary).
  ///
  /// Returns a [LatLng] instance describing the given geolocation, or null if
  /// [value] is null or does not represent a valid geolocation.
  factory LatLng.parse(String value) {
    if (value == null) {
      return null;
    }
    final List<String> components = value.split(',');
    if (components.length != 2) {
      return null;
    }
    try {
      return LatLng(double.parse(components[0]), double.parse(components[1]));
    } catch (e) {
      return null;
    }
  }

  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;

  @override
  String toString() => '$lat,$lng';
}
