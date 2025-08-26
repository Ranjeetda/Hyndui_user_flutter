import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../resource/pref_utils.dart';
import 'URLS.dart';

class MytripesProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List <dynamic> _myTripsListData=[];
  List<dynamic> get myTripsListData => _myTripsListData;

  Future<void> loadMyTripsService(
      String offset,
      String limit,
      String travelStatus,
      ) async {
    _isLoading = true;
    notifyListeners();
    final url = Uri.parse(URLS.userMyTrips);
    try {

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          "Authorization": PrefUtils.getBearerToken() ?? "",

        },
        body: {
          "offset": offset,
          "limit": limit,
          "travel_status": travelStatus,
        },
      );
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        print("✅ My trips Response: ${response.body}");
        _myTripsListData = jsonResponse['data'];
        notifyListeners();
      } else {
        _isLoading = false;
        notifyListeners();
        print("❌ My trips Failed: ${response.body}");
        _myTripsListData = jsonResponse['data'];
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      print("❗ Exception occurred: $error");
      throw Exception('Failed to fetch My trips data: $error');
    }
  }
}
