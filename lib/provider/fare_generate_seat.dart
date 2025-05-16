import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class FareGenerateSeat with ChangeNotifier {

  Future<http.Response> sendFareGenerateRequestService(
      String busId,
      String routeId,
      String busScheduleId,
      String pickupStopId,
      String dropStopId,
      String seatNo,
      String currentDate,
      String hasReturn,
      ) async {
    final url = Uri.parse(URLS.fareGenerateSeat);
    final headers = {
      "Content-Type": "application/json",
      "Authorization": PrefUtils.getBearerToken() ?? "",
    };
    final body = json.encode({
      "bus_id": busId,
      "route_id": routeId,
      "busschedule_id": busScheduleId,
      "pickup_stop_id": pickupStopId,
      "drop_stop_id": dropStopId,
      "seat_no": seatNo,
      "start_date": currentDate,
      "has_return": hasReturn,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("✅ Fare Generate Response: ${response.body}");
        return response;
      } else {
        print("❌ Fare Generate Failed: ${response.body}");
        return response; // still return to handle gracefully in UI
      }
    } catch (error) {
      print("❗ Exception occurred: $error");
      throw Exception('Failed to fetch fare generate data: $error');
    }
  }
}
