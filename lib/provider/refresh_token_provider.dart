
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class RefreshTokenProvider with ChangeNotifier {

  Future<http.Response> refreshToken() async {
    final url = Uri.parse(URLS.refreshToken);
    print("RanjeetTest ==========> phone " +PrefUtils.getPhone()!);
    print("RanjeetTest ==========> csrfToken " +PrefUtils.getCsrfToken()!);
    print("RanjeetTest ==========> onModel " +"User");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'phone': PrefUtils.getPhone(),
          'csrfToken': PrefUtils.getCsrfToken(),
          'onModel': "User",
        },
      );

      if (response.statusCode == 200) {
        print("✅ Refresh Token Response: ${response.body}");
        return response;
      } else {
        print("❌ Refresh Token Failed: ${response.body}");
        return response;
      }
    } catch (error) {
      print("❗ Exception occurred: $error");
      throw Exception('Failed to fetch refresh token data: $error');
    }
  }
}
