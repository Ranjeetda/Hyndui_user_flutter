import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class VerifyRegisterUserProvider with ChangeNotifier {
  Future<http.Response> sendVeryUserRequestService(String deviceToken, String deviceType, String otp, bool isMobileVerified,String deviceInfo) async {
    final url = Uri.parse(URLS.verifyUser);
    final headers = {
      "Content-Type": "application/json",
      "Authorization": PrefUtils.getBearerToken()!,
    };
    final body = json.encode({
      "device_token": deviceToken,
      "device_type": int.parse(deviceType),
      "otp": int.parse(otp),
      "is_mobile_verified": isMobileVerified,
      "device_info": deviceInfo
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Response Register Verify ===========> ${response.body}");
        return response;
      } else {
        print('Response Register Verify failed: ${response.body}');
        return response;
      }
    } catch (error) {
      throw Exception('Failed to register veriy in: $error');
    }
  }
}
