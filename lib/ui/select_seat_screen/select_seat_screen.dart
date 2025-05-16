import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lmm_user/resource/app_colors.dart';
import 'package:lmm_user/resource/image_paths.dart';
import 'package:lmm_user/resource/pref_utils.dart';
import 'package:provider/provider.dart';
import '../../provider/bus_seat_provider.dart';
import '../../provider/fare_generate_seat.dart';
import '../../resource/Utils.dart';
import '../confirm_payment_screen/confirm_payment_screen.dart';
import '../message_screen/chat_message.dart';
import '../model/seat_model.dart';
import '../navigation_screen/bottom_navigation_bar.dart';

class SelectSeatScreen extends StatefulWidget {
  final String routeId;
  final String route_timetableId;
  final String busId;
  final String pickupId;
  final String dropId;
  final String stops;
  final String bookingType;
  final String has_return;
  final String currentDate;
  final String endDate;

  SelectSeatScreen(
      this.routeId,
      this.route_timetableId,
      this.busId,
      this.pickupId,
      this.dropId,
      this.stops,
      this.bookingType,
      this.has_return,
      this.currentDate,
      this.endDate, {
        Key? key,
      }) : super(key: key);

  @override
  State<SelectSeatScreen> createState() => _SelectSeatScreenState();
}

class _SelectSeatScreenState extends State<SelectSeatScreen> {
  bool isExpend = false;
  bool isExpend1 = false;
  String? selectedSeatNo;

  List<BusSeatItem> busSeatsList = [];
  List<SeatModel> seatModelsItemsList = [];
  List<EdgeItem> abstractItemsList = [];
  List<EdgeItemNew> seatModelsBookedItemsList = [];
  Map<String, dynamic> _faredata = {};

  var seatPrice = '';
  var tax = '';
  var mTicket = '';
  String defaultCurrency = "₹";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBusSeat();
    });
  }

  Future<void> _fetchBusSeat() async {
    Utils.showLoadingDialog(context);
    try {
      final response =
      await Provider.of<BusSeatProvider>(context, listen: false)
          .sendBusSeatRequestService(
        widget.busId,
        widget.routeId,
        widget.route_timetableId,
        widget.pickupId,
        widget.dropId,
        widget.bookingType,
        widget.has_return,
        widget.currentDate,
        widget.endDate,
      );

      var responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        List<dynamic>? combineSeats = [];

        for (int i = 0;
        i < responseData['data']['buslayoutId']['combine_seats'].length;
        i++) {
          if (responseData['data']['buslayoutId']['combine_seats'][i].length !=
              0) {
            combineSeats.add(
                responseData['data']['buslayoutId']['combine_seats'][i][0]);
          }
        }
        initializeSeats(combineSeats);

        if(widget.bookingType=='office'){
          PrefUtils.setOfficePickupAdd(responseData['data']['pickup_name']);
          PrefUtils.setOfficeDropAdd(responseData['data']['drop_name']);
          PrefUtils.setOfficeBookingDate(responseData['data']['created_date']);

          PrefUtils.setOfficePickupTime(responseData['data']['pickup_time']);
          PrefUtils.setOfficeDropTime(responseData['data']['drop_time']);
          PrefUtils.setOfficeBusName(responseData['data']['bus_name']);
          PrefUtils.setWalletBalance(responseData['data']['user_total_wallet_amount'].toString());

        }

        setState(() {
          seatPrice = responseData['data']['final_total_fare'];
          tax = responseData['data']['tax_amount'];
          double seatPrices = double.parse(seatPrice);
          double taxs = double.parse(tax);
          double priceWithoutTax = seatPrices - taxs;
          mTicket = priceWithoutTax.toString();
        });
      } else {
        String errorMessage = responseData['message'] ??
            'Bus seat fetch failed. Please try again.';
        Utils.showErrorMessage(context, errorMessage);
      }
    } catch (e) {
      Utils.showErrorMessage(context, 'An error occurred. Please try again.');
    } finally {
      Utils.hideLoadingDialog();
    }
  }

  Future<void> _getFareSeat() async {
    Utils.showLoadingDialog(context);
    try {
      final response =
      await Provider.of<FareGenerateSeat>(context, listen: false)
          .sendFareGenerateRequestService(
        widget.busId,
        widget.routeId,
        widget.route_timetableId,
        widget.pickupId,
        widget.dropId,
        selectedSeatNo!,
        widget.currentDate,
        widget.has_return,
      );

      var responseData = json.decode(response.body);
      if (responseData['status'] == true) {

        _faredata=responseData['data'];
      } else {
        String errorMessage = responseData['message'] ??
            'Fare data fetch failed. Please try again.';
        Utils.showErrorMessage(context, errorMessage);
      }
    } catch (e) {
      Utils.showErrorMessage(context, 'An error occurred. Please try again.');
    } finally {
      Utils.hideLoadingDialog();
    }
  }

  void initializeSeats(List<dynamic>? combineSeats) {
    try {
      if (combineSeats == null || combineSeats.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Something went wrong")));
        return;
      }

      for (int j = 0; j < combineSeats.length; j++) {
        if (combineSeats[j].isNotEmpty) {
          final seatMap = combineSeats[j];
          final seat = BusSeatItem.fromJson(seatMap);

          busSeatsList.add(seat);

          if (seat.seatStatus?.toLowerCase() == "empty") {
            seatModelsItemsList.add(
              SeatModel(
                  seat.isLadies == true ? SeatType.ladies : SeatType.empty),
            );
          } else if (seat.seatStatus?.toLowerCase() == "booked") {
            seatModelsItemsList.add(SeatModel(SeatType.booked));
          }

          abstractItemsList.add(EdgeItem(seat.seatNo, seat.isFemale));
          seatModelsBookedItemsList.add(EdgeItemNew(seat.isFemale));
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint("initializeSeats error: $e");
    }
  }

  void getSelectedSeats(String seatNo) {
    setState(() {
      selectedSeatNo = seatNo;
    });
  }

  Widget buildSeat({required Color color}) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget buildSeatGrid() {
    return Expanded(
      flex: 1,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
          (MediaQuery.of(context).size.width / 60).floor(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: busSeatsList.length,
        itemBuilder: (context, index) {
          final seatModel = seatModelsItemsList[index];
          final seat = busSeatsList[index];

          Color? color;
          switch (seatModel.type) {
            case SeatType.empty:
              color = Colors.green;
              break;
            case SeatType.booked:
              color = Colors.grey;
              break;
            case SeatType.ladies:
              color = Colors.grey[300];
              break;
          }

          final isSelected = selectedSeatNo == seat.seatNo;

          return GestureDetector(
            onTap: () {
              if (seatModel.type == SeatType.booked) return;

              final tappedSeat = seat.seatNo;

              if (selectedSeatNo == tappedSeat) {
                setState(() {
                  selectedSeatNo = null;
                  isExpend = false;

                });
                return;
              }

              if (selectedSeatNo == null) {
                isExpend = true;

                getSelectedSeats(tappedSeat ?? "");
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "You are only allowed to book one seat at a time."),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black),
              ),
              child: Center(
                child: Text(
                  seat.seatNo ?? "--",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Select Seat", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CustomBottomNavigationBar()));
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    buildSeat(color: Colors.grey.shade300),
                    const SizedBox(height: 4),
                    const Text("Available"),
                  ],
                ),
                Column(
                  children: [
                    buildSeat(color: Colors.grey),
                    const SizedBox(height: 4),
                    const Text("Booked"),
                  ],
                ),
                Column(
                  children: [
                    buildSeat(color: const Color(0xFF0A2D5F)),
                    const SizedBox(height: 4),
                    const Text("Selected"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Text("Stops",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(Icons.circle,
                                  color: Color(0xFF0A2D5F), size: 12),
                              DottedLine(),
                              Icon(Icons.circle,
                                  color: Color(0xFF0A2D5F), size: 12),
                              DottedLine(),
                              Icon(Icons.location_pin,
                                  color: Color(0xFF0A2D5F), size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(ImagePaths.streengWheel),
                          ],
                        ),
                        const SizedBox(height: 12),
                        buildSeatGrid(),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Booking Panel
            Visibility(
              visible: isExpend,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: Opacity(
                            opacity: 0.1,
                            child: Image.asset(
                              ImagePaths.ticket,
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 4),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Ticket Price',
                                      style: TextStyle(
                                          fontFamily: 'GoogleSansBold',
                                          fontSize: 18,
                                          color: Color(0xFF1A1A1A))),
                                  Text('₹$mTicket',
                                      style: const TextStyle(
                                          fontFamily: 'GoogleSansBold',
                                          fontSize: 18,
                                          color: Color(0xFF1A1A1A))),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:  [
                                Text('Taxes',
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansBold',
                                        fontSize: 18,
                                        color: Color(0xFF1A1A1A))),
                                Text(tax,
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansBold',
                                        fontSize: 16,
                                        color: Color(0xFF7A7A7A))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Price',
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansBold',
                                        fontSize: 18,
                                        color: Color(0xFF0A2D5F))),
                                Text('₹${seatPrice}',
                                    style: const TextStyle(
                                        fontFamily: 'GoogleSansBold',
                                        fontSize: 18,
                                        color: Color(0xFF0A2D5F))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isExpend = false;
                            isExpend1 = true;
                            _getFareSeat();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A2D5F),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Book Now',
                            style: TextStyle(
                                fontFamily: 'GoogleSansBold',
                                fontSize: 18,
                                color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Payment Options
            Visibility(
              visible: isExpend1,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ConfirmPaymentScreen('Booking',selectedSeatNo!,_faredata)),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE8F0FE),
                          radius: 20,
                          child: Icon(Icons.confirmation_num_outlined,
                              color: Colors.blue.shade700),
                        ),
                        title: const Text('Pay Per Ride',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: const Text('Proceed to pay ₹30 for this ride',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ),
                    ),
                    const Divider(indent: 16, endIndent: 16, height: 1),
                    InkWell(onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatMessage('Booking',selectedSeatNo!,_faredata),
                        ),
                      );
                    },
                      child:  ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF1F3F4),
                          radius: 20,
                          child: Icon(Icons.chat_bubble_outline,
                              color: Colors.black87),
                        ),
                        title: const Text('Chat with driver',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: const Text('Price negotiation with driver',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DottedLine extends StatelessWidget {
  const DottedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}
