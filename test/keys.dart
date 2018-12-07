// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'dart:convert';
import 'dart:io';

// ignore_for_file: avoid_as
class Keys {
  Keys() {
    final String data =
        File('${Directory.current.path}/test/key.json').readAsStringSync();
    final Map keys = jsonDecode(data);
    applicationID = keys['applicationId'] as String;
    apiKey = keys['apiKey'] as String;
  }

  String applicationID;
  String apiKey;

  String get longApiKey =>
      String.fromCharCodes(List<int>.generate(65000, (_) => 'c'.codeUnitAt(0)));
}
