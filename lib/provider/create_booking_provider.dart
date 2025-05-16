import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class CreateBookingProvider with ChangeNotifier {

  Future<http.Response> createBookingRequestService(
      Map<String, dynamic> jsonData
      ) async {
    final url = Uri.parse(URLS.bookingCreate);
    final headers = {
      "Content-Type": "application/json",
      "Authorization": PrefUtils.getBearerToken() ?? "",
    };
    final body = json.encode(jsonData);

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("✅ Create Booking Response: ${response.body}");
        return response;
      } else {
        print("❌ Create Booking Failed: ${response.body}");
        return response; // still return to handle gracefully in UI
      }
    } catch (error) {
      print("❗ Exception occurred: $error");
      throw Exception('Failed to fetch fare generate data: $error');
    }
  }
}
