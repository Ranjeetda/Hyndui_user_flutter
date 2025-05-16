import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class RouteExploreProvider with ChangeNotifier {
  List <dynamic> _routeExploreData=[];
  List<dynamic> get routeExploreData => _routeExploreData;


  Future<void> fetchRouteExplore() async {
    try {
      final url = Uri.parse(URLS.routeExplore);

      final response = await http.get(url,
        headers: {
          "Authorization": PrefUtils.getBearerToken()!,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Response RouteExplore ===========> ${response.body}");

        if (jsonResponse['status'] == true) {

          _routeExploreData = jsonResponse['data'];

          notifyListeners();
        } else {
          throw Exception(
              'Failed to fetch notices: ${jsonResponse['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token.');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: Authorization token required.');
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('Failed to load notices: $error');
    }
  }
}
