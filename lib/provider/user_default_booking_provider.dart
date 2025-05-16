import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class UserDefaultBookingProvider with ChangeNotifier {
  Map<String, dynamic> _userDefoultBookingData={};
  List<dynamic> _defaultBookingList=[];
  List<dynamic> get defaultBookingList => _defaultBookingList;

  Map<String, dynamic> get userDefoultBookingData => _userDefoultBookingData;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<http.Response> userDefaultBookRequestService() async {
    final url = Uri.parse(URLS.userDefaultBooking);
    _isLoading = true;

    final headers = {
      "Content-Type": "application/json",
      "Authorization": PrefUtils.getBearerToken()!,
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        print("Response user Default ===========> ${response.body}");
        _userDefoultBookingData = jsonDecode(response.body);
        _defaultBookingList = _userDefoultBookingData['data'];
        return response;
      } else {
        _isLoading = false;
        notifyListeners();
        _userDefoultBookingData = jsonDecode(response.body);
        print('Response user Default  failed: ${response.body}');
        return response;
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to user Default  in: $error');
    }
  }
}
