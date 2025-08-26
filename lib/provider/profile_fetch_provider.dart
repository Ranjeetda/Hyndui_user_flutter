import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class ProfileFetchProvider with ChangeNotifier {

  Future<http.Response> fetchProfile() async {
    final url = Uri.parse(URLS.profileFetch);
    print("RanjeetTest ==========> " +PrefUtils.getBearerToken()!);
    final headers = {
      "Authorization": PrefUtils.getBearerToken()!,
    };
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        print("Response Profile Fetch  ===========> ${response.body}");
        return response;
      } else {
        print('Response Profile Fetch  failed: ${response.body}');
        return response;
      }
    } catch (error) {
      throw Exception('Failed to Profile Fetch  in: $error');
    }
  }
}
