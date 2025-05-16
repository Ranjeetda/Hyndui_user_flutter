import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmm_user/resource/pref_utils.dart';
import 'URLS.dart';

class PaymentPayProvider with ChangeNotifier {

  Future<http.Response> initiateTripPayment({
    required String type,
    required String paymentName,
    required double amount,
    required String paymentMode,
    required String pnrNo,
  }) async {
    final uri = Uri.parse(URLS.paymentPay).replace(queryParameters: {
      'type': type,
      'payment_name': paymentName,
      'amount': amount.toString(),
      'payment_mode': paymentMode,
      'pnr_no': pnrNo,
    });

    final headers = {
      "Content-Type": "application/json",
      "Authorization": PrefUtils.getBearerToken() ?? "",
    };

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print("✅ Payment pay Response: ${response.body}");
        return response;
      } else {
        print("❌ Payment pay Failed: ${response.body}");
        return response; // still return to handle gracefully in UI
      }
    } catch (error) {
      print("❗ Exception occurred: $error");
      throw Exception('Failed to Payment pay generate data: $error');
    }

  }

}
