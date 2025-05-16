import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'URLS.dart';

class SendChatProvider with ChangeNotifier {

  Future<http.Response> sendChat(
      String bookingId,
      String sentBy,
      String chatType,
      String amount,
      String message,
      String isFinalPrice
      ) async {
    final url = Uri.parse(URLS.postChat);
    print("RanjeeTest"+"bookingId========> "+bookingId);
    print("RanjeeTest"+"setBy========> "+"User");
    print("RanjeeTest"+"chatType========> "+chatType);
    print("RanjeeTest"+"amount========> "+amount);
    print("RanjeeTest"+"message========> "+message);
    print("RanjeeTest"+"isFinal========> "+isFinalPrice);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'bookingId': bookingId,
          'sentBy': sentBy,
          'chatType': chatType,
          'amount': amount,
          'message': message,
          'isFinalPrice': isFinalPrice,
        },
      );

      if (response.statusCode == 200) {
        print("✅ Send Chat Response: ${response.body}");
        return response;
      } else {
        print("❌ Send Chat Failed: ${response.body}");
        return response;
      }
    } catch (error) {
      print("❗ Exception occurred: $error");
      throw Exception('Failed to fetch send chat data: $error');
    }
  }
}
