import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class RouteSearchProvider with ChangeNotifier {
  Map<String, dynamic> _rootData={};
  Map<String, dynamic> get rootData => _rootData;

  Future<http.Response> sendSearchRootRequestService(String pickup_lat, String pickup_long, String drop_lat,String drop_long,String current_date,
      String current_time,String end_date,String type,String pickup_id,String drop_id,String has_return) async {
    final url = Uri.parse(URLS.routeSearch);

    final headers = {
      "Content-Type": "application/json",
      "Authorization": PrefUtils.getBearerToken()!,
    };
    final body = json.encode({
     "pickup_lat": pickup_lat,
    "pickup_long": pickup_long,
    "drop_lat": drop_lat,
    "drop_long": drop_long,
    "current_date": current_date,
    "current_time": "00:00",
    "end_date": end_date,
    "type":type,
    "pickup_id":pickup_id,
    "drop_id":drop_id,
    "has_return":has_return

    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Response Search Root ===========> ${response.body}");
        _rootData = jsonDecode(response.body);
        return response;
      } else {
        _rootData = jsonDecode(response.body);
        print('Response Search Root  failed: ${response.body}');
        return response;
      }
    } catch (error) {
      throw Exception('Failed to Search Root  in: $error');
    }
  }
}
