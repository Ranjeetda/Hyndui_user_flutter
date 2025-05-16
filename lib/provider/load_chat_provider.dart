import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'URLS.dart';

class LoadChatProvider with ChangeNotifier {
  List <dynamic> _chatListData=[];
  List<dynamic> get chatListData => _chatListData;

  Future<void> loadChatService(
      String bookingId,
      String userId,
      String sentBy,
      String chatType,
      String driverId
      ) async {

    print("bookingId ===========>$bookingId" );
    print("chatType ===========>$chatType" );
    final url = Uri.parse(URLS.loadChat);

    try {

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          "bookingId": bookingId,
          "userId": userId,
          "sentBy": sentBy,
          "chatType": chatType,
          "driverId": driverId,
        },
      );
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        print("✅ Load Chat Response: ${response.body}");
        _chatListData = jsonResponse['data'];

        notifyListeners();
      } else {
        print("❌ Load Chat Failed: ${response.body}");
        _chatListData = jsonResponse['data'];
      }
    } catch (error) {
      print("❗ Exception occurred: $error");
      throw Exception('Failed to fetch load chat data: $error');
    }
  }
}
