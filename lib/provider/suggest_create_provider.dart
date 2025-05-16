import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class SuggestCreateProvider with ChangeNotifier {

  Future<http.Response> sendSuggestRootRequestService(String pickup_address, String pickup_lat, String pickup_lng,String drop_address,String drop_lat,String drop_lng,String pickup_city,String pickup_state,String drop_city,String drop_state) async {
    final url = Uri.parse(URLS.suggestCreate);
    final headers = {
      "Content-Type": "application/json",
      "Authorization": PrefUtils.getBearerToken()!,
    };
    final body = json.encode({
      "pickup_address": pickup_address,
      "pickup_lat": pickup_lat,
      "pickup_lng": pickup_lng,
      "drop_address": drop_address,
      "drop_lat": drop_lat,
      "drop_lng": drop_lng,
      "pickup_city": pickup_city,
      "pickup_state": pickup_state,
      "drop_city": drop_city,
      "drop_state": drop_state,

    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Response Suggest Root ===========> ${response.body}");
        return response;
      } else {
        print('Response Suggest Root  failed: ${response.body}');
        return response;
      }
    } catch (error) {
      throw Exception('Failed to Suggest Root  in: $error');
    }
  }
}
