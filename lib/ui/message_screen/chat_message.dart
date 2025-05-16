import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/create_booking_provider.dart';
import '../../provider/load_chat_provider.dart';
import '../../provider/send_chat_provider.dart';
import '../../resource/Utils.dart';
import '../../resource/app_colors.dart';
import '../../resource/pref_utils.dart';

class ChatMessage extends StatefulWidget {
  String comingFrom;
  String seatNo;
  Map<String, dynamic> _faredata = {};

  ChatMessage(this.comingFrom, this.seatNo,this._faredata);

  @override
  _ChatMessage createState() => _ChatMessage();
}

class _ChatMessage extends State<ChatMessage> {
  final TextEditingController _messageController = TextEditingController();
  var chatTyep;
  bool isFinal=false;
  var amount="";
  Timer? _timer;
  String bookingId="";



  final List<Map<String, dynamic>> messages = [
    {"text": "Hello! How can I help you?", "isMe": false},
  ];


  @override
  void initState() {
    super.initState();
    if(widget.comingFrom=="SCHEDULED") {
      chatTyep="2";
    }else{
      chatTyep="1";
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createBooing();
    });
  }


  Future<void> _createBooing() async {
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
        bookingId=responseData['data']['persistedPassenger'][0]['bookingId'];
        _timer = Timer.periodic(Duration(seconds: 5), (timer) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<LoadChatProvider>(context, listen: false).loadChatService(bookingId, "", "", chatTyep, "");
          });
        });

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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  Future<void> sendMessage(String bookingId,String amount,String message ,bool isFinal,String chatType) async {
    try {


      final response =
      await Provider.of<SendChatProvider>(context, listen: false)
          .sendChat(bookingId, "User", chatType, amount, message,isFinal.toString());

      var responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        if (!mounted) return;
        if (responseData['status'] == true) {}
      } else {
        String errorMessage = responseData['message'] ??
            'Fare data fetch failed. Please try again.';
        Utils.showErrorMessage(context, errorMessage);
      }
    } catch (e) {
      Utils.showErrorMessage(context, 'An error occurred. Please try again.');
    } finally {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Chat", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Consumer<LoadChatProvider>(
            builder: (context, provider, _) {
              if (provider.chatListData.isEmpty) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatBubble(
                        text: message['text'],
                        isMe:  message['isMe'],
                      );
                    },
                  ),
                );
              } else {
                return  Expanded(
                  child: ListView.builder(
                    itemCount: provider.chatListData.length,
                    itemBuilder: (context, index) {
                      final message = provider.chatListData[index];
                      bool isMe=false;
                      if(message['sentBy']=="User"){
                        isMe=true;
                      }else{
                        isMe=false;
                      }

                      return ChatBubble(
                        text: message['message'],
                        isMe: isMe,
                      );
                    },
                  ),
                );
              }
            },
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _messageController,
                        decoration:
                            InputDecoration(hintText: "Type a message"))),
                IconButton(icon: Icon(Icons.send), onPressed: () {

                  var messageText = _messageController.text;
                  if (messageText.isNotEmpty) {

                    if(messageText=="done"||messageText=="ok"){
                      isFinal=true;
                    }
                    var str = messageText;
                    var regex = RegExp(r'\d+');
                    var match = regex.firstMatch(str);

                    if (match != null) {
                      var numberString = match.group(0);
                      var number = int.parse(numberString!);
                      print("Extracted integer: $number") ;
                    } else {
                      print("No integer found");
                    }
                    if(widget.comingFrom=="SCHEDULED"){
                      sendMessage(bookingId,amount,messageText,isFinal,"2");

                    }else{
                      sendMessage(bookingId,amount,messageText,isFinal,"1");

                    }

                    _messageController.clear();

                  }
                })
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  ChatBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
