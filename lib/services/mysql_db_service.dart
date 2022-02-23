import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

enum RequestType { GET, POST }

class MySqlDBService {
  // This is singleton class to prevent creating instance more then one.
  static final MySqlDBService _mySqlDBService = MySqlDBService._internal();

  MySqlDBService._internal();

  factory MySqlDBService() {
    return _mySqlDBService;
  }

  // Getting phpData
  Future<Map<String, dynamic>> runQuery({
    required RequestType requestType,
    required String url,
    Map<String, String> headers = const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Charset': 'utf-8',
    },
    Map<String, String>? body,
  }) async {
    var response = requestType == RequestType.GET
        ? await http.get(
            Uri.parse(url),
            headers: headers,
          )
        : await http.post(
            Uri.parse(url),
            headers: headers,
            body: convert.jsonEncode(body),
          );
    var jsonResponse;
    try {
      if (response.statusCode == 200) {
        jsonResponse = convert.jsonDecode(response.body);
        //print('JSON RESPONSE: ${jsonResponse.toString()}');
        return {'status': true, 'error': null, 'data': jsonResponse};
      } else {
        print('JSON RESPONSE ERROR STATUS CODE: ${response.statusCode}');
        return {
          'status': false,
          'error': response.statusCode.toString(),
          'data': null
        };
      }
    } catch (e) {
      print('Printing Error');
      print(e);
      return {'status': false, 'error': e.toString(), 'data': null};
    }
  }
}
