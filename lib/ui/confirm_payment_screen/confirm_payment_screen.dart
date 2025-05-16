import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lmm_user/resource/pref_utils.dart';
import 'package:lmm_user/ui/confirm_payment_screen/payment_web_view_screen.dart';
import 'package:provider/provider.dart';

import '../../provider/create_booking_provider.dart';
import '../../provider/payment_pay_provider.dart';
import '../../resource/Utils.dart';
import '../../resource/app_colors.dart';

class ConfirmPaymentScreen extends StatefulWidget {
  String comingFrom;
  String seatNo;
  Map<String, dynamic> _faredata = {};

  ConfirmPaymentScreen(this.comingFrom, this.seatNo, this._faredata);

  @override
  State<ConfirmPaymentScreen> createState() => _ConfirmPaymentScreenState();
}

class _ConfirmPaymentScreenState extends State<ConfirmPaymentScreen> {
  var mTotalFare="";
  var paymentMode = "ONLINE";
  var cash = "CASH";
  var paymentName = "Razorpay";
  var paymentType = "trip";
  var online = "ONLINE";
  var pnrNumber = "";
  var bookingId="";
  bool isLoading = false;
  bool isChecked = false;


  Future<void> _paymentPay() async {
    try {
      setState(() {
        isLoading = true;
      });

      double? amount = double.tryParse(mTotalFare);
      if (amount == null) {
        setState(() {
          isLoading = false;
        });
        Utils.showErrorMessage(context, 'Invalid amount format.');
        return;
      }

      final response = await Provider.of<PaymentPayProvider>(context, listen: false)
          .initiateTripPayment(
        type: paymentType,
        paymentName: paymentName,
        amount: amount,
        paymentMode: paymentMode,
        pnrNo: pnrNumber,
      );

      var responseData = json.decode(response.body);
      setState(() {
        isLoading = false;
      });


      if (responseData['status'] == true && paymentMode ==online) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(url: responseData['gateway_url'],),
          ),
        );

      }else if (responseData['status'] == true &&paymentMode==cash) {
        showBookingSuccessDialog(context);

      } else {

      }

      if (responseData['status'] == true) {
        showBookingSuccessDialog(context);
      } else {
        String errorMessage = responseData['message'] ?? 'Payment pay failed. Please try again.';
        Utils.showErrorMessage(context, errorMessage);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Utils.showErrorMessage(context, 'An error occurred. Please try again.');
    }
  }


  Future<void> _createBooing() async {
    pnrNumber=  widget._faredata['pnr_no'].toString();
    mTotalFare= widget._faredata['final_total_fare'];
    final Map<String, dynamic> jsonData = {
      "offer_code": "",
      "fareData": {
        "bus_id": widget._faredata['bus_id'],
        "created_date": widget._faredata['created_date'],
        "distance": widget._faredata['distance'],
        "drop_name": widget._faredata['drop_name'],
        "drop_stop_id": widget._faredata['drop_stop_id'],
        "drop_time": widget._faredata['drop_time'],
        "fee": widget._faredata['fee'],
        "final_total_fare": widget._faredata['final_total_fare'],
        "has_return": widget._faredata['has_return'],
        "no_of_seats": widget._faredata['no_of_seats'],
        "pickup_name": widget._faredata['pickup_name'],
        "pickup_stop_id": widget._faredata['pickup_stop_id'],
        "pickup_time": widget._faredata['pickup_time'],
        "pnr_no": widget._faredata['pnr_no'],
        "route_id": widget._faredata['route_id'],
        "busschedule_id": widget._faredata['busschedule_id'],
        "seat_no": widget._faredata['seat_no'],
        "sub_total": widget._faredata['sub_total'],
        "tax": widget._faredata['tax'],
        "tax_amount": widget._faredata['tax_amount'],
      },
      "passengerDetailsItem": [
        {
          "age": "",
          "fullname": PrefUtils.getuserName(),
          "gender": PrefUtils.getGender(),
          "pick_address": PrefUtils.getPickupAddress(),
          "pick_lang": PrefUtils.getPickupLan(),
          "pick_lat": PrefUtils.getPickupLat(),
          "seat": widget.seatNo
        }
      ]
    };

    Utils.showLoadingDialog(context);
    try {
      final response =
      await Provider.of<CreateBookingProvider>(context, listen: false)
          .createBookingRequestService(jsonData);

      var responseData = json.decode(response.body);
      print("✅ Create Booking Response: ${response.body}");

      if (responseData['status'] == true) {

      } else {
        String errorMessage = responseData['message'] ??
            'Create Booking  failed. Please try again.';
        Utils.showErrorMessage(context, errorMessage);
      }
    } catch (e) {
      Utils.showErrorMessage(context, 'An error occurred. Please try again.');
    } finally {
      Utils.hideLoadingDialog();
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createBooing();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text(
          "Confirm Payment",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF8F8F8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Row
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2A66),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          Utils.convertDateToBeautifyString(
                              PrefUtils.getOfficeBookingDate()),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.circle,
                              size: 12, color: Colors.green),
                          Container(
                            width: 2,
                            height: 16,
                            color: Colors.grey.shade400,
                          ),
                          const Icon(Icons.circle, size: 12, color: Colors.red),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(PrefUtils.getOfficePickupAdd()),
                          SizedBox(height: 12),
                          Text(PrefUtils.getOfficeDropAdd()),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  // Time + Bus Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${PrefUtils.getOfficePickupTime()}  -  ${PrefUtils
                          .getOfficeDropTime()}"),
                      Row(
                        children: [
                          Text(PrefUtils.getOfficeBusName()),
                          SizedBox(width: 8),
                          Icon(Icons.directions_bus, color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Seat Number"),
                      Row(
                        children: [
                          Text(widget.seatNo),
                          SizedBox(width: 8),
                          Icon(Icons.accessible_forward_rounded,
                              color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Pay from Cash Checkbox
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFF8F8F8),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                        if(isChecked) {
                          paymentMode = cash;
                        }else{
                          paymentMode = online;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text('Pay from Cash'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Promo Code Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter Promo Code",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFF0A2A66),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: const Text(
                    "Apply",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Fare Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ride Fare",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Tax included in fare",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Text("₹ ${widget._faredata['final_total_fare']}",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Spacer(),
          // Confirm & Pay Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2A66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _paymentPay();

                },
                child:  isLoading
                    ? const CircularProgressIndicator(
                    color: Colors.white)
                    : const Text(
                  "Confirm & Pay",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'TitilliumWeb',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void showBookingSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checkmark Icon
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF0A2A66),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Title
                const Text(
                  'Success',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Message
                const Text(
                  '"Your booking has been confirmed !"',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A2A66),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Handle Ok action here
                        },
                        child: const Text(
                          "Ok",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 1),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A2A66),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Handle No action here
                        },
                        child: const Text(
                          "No",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
