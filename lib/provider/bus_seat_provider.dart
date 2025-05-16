import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class BusSeatProvider with ChangeNotifier {
  // Fetch bus seat availability
  Future<http.Response> sendBusSeatRequestService(
      String busId,
      String routeId,
      String busScheduleId,
      String pickupStopId,
      String dropStopId,
      String type,
      String hasReturn,
      String currentDate,
      String endDate,
      ) async {
    final url = Uri.parse("${URLS.busesSeat}$busId");

    final headers = {
      "Content-Type": "application/json",
      "Authorization": PrefUtils.getBearerToken() ?? "",
    };

    final body = json.encode({
      "route_id": routeId,
      "busschedule_id": busScheduleId,
      "pickup_stop_id": pickupStopId,
      "drop_stop_id": dropStopId,
      "type": type,
      "has_return": hasReturn,
      "current_date": currentDate,
      "end_date": endDate,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("✅ Bus Seat Response: ${response.body}");
        return response;
      } else {
        print("❌ Bus Seat Failed: ${response.body}");
        return response; // still return to handle gracefully in UI
      }
    } catch (error) {
      print("❗ Exception occurred: $error");
      throw Exception('Failed to fetch bus seat data: $error');
    }
  }
}
