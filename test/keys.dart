// File created by
// Lung Razvan <long1eu>
// on 2018-12-05

import 'dart:convert';
import 'dart:io';

class Keys {
  Keys({bool places = false}) {
    final File file = File('${Directory.current.path}/test/key.json');
    final String data = file.existsSync() ? file.readAsStringSync() : jsonModel;
    Map keys = jsonDecode(data);
    if (places) {
      keys = keys['places'] as Map;
    }

    applicationID = keys['applicationId'] as String;
    apiKey = keys['apiKey'] as String;
  }

  factory Keys.places() => Keys(places: true);

  String applicationID;
  String apiKey;

  String get longApiKey =>
      String.fromCharCodes(List<int>.generate(65000, (_) => 'c'.codeUnitAt(0)));
}

const String jsonModel = '''
{
  "applicationId": "APP_ID",
  "apiKey": "API_KEY",
  "places": {
    "applicationId": "PLACES_APP_ID",
    "apiKey": "PLACES_API_KEY"
  }
}
''';
