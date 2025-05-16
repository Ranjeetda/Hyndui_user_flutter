import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'URLS.dart';

class RegisterUserProvider with ChangeNotifier {

  Future<http.Response> sendRequestService(String cCode, String phone, String deviceToken, String countryDetail,String language) async {
    final url = Uri.parse(URLS.SIGN_IN_URL);
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "country_code": cCode,
      "phone": phone,
      "device_id": deviceToken,
      "country_details": countryDetail,
      "language": language
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Response Register ===========> ${response.body}");
        return response;
      } else {
        print('Response Register failed: ${response.body}');
        return response;
      }
    } catch (error) {
      throw Exception('Failed to sign in: $error');
    }
  }
}
