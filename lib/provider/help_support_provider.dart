import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class HelpSupportProvider with ChangeNotifier {
  Future<http.Response> sendHelpSupportRequestService(String contact, String helpemail, String description) async {
    final url = Uri.parse(URLS.verifyUser);
    final headers = {
      "Content-Type": "application/json",
      "Authorization": PrefUtils.getBearerToken()!,
    };

    final body = json.encode({
      "contact": contact,
      "helpemail": helpemail,
      "description": description,

    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Response Help & Support ===========> ${response.body}");
        return response;
      } else {
        print('ResponseHelp & Support failed: ${response.body}');
        return response;
      }
    } catch (error) {
      throw Exception('Failed to Help & Support in: $error');
    }
  }
}
