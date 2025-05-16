import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/booking_history_provider.dart';
import '../../resource/Utils.dart';

class BookingHistory extends StatefulWidget {
  @override
  _BookingHistoryState createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  bool isExpanded = false;
  var offSet = 0;
  var limit = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingHistoryProvider>(context, listen: false).fetchBookingHistory(offset: offSet, limit: limit);
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
            "Booking History",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Color(0xFF023E8A),
        ),
        body: Consumer<BookingHistoryProvider>(
          builder: (context, provider, _) {
            if (provider.bookingHistoryData.isEmpty) {
              return Center(child: Utils.buildLoader());
            } else {
              return ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: provider.bookingHistoryData.length,
                itemBuilder: (context, index) {
                  return _buildVehicleCard(provider.bookingHistoryData[index]);
                },
              );
            }
          },
        ),
    );
  }


  Widget _buildVehicleCard(dynamic bookingHistoryData) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.directions_bus, color: Colors.red, size: 30),
                  ),

                  const SizedBox(width: 16),

                  // Middle content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookingHistoryData['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bookingHistoryData['method'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bookingHistoryData['payment_created'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side - Price and Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹'+bookingHistoryData['amount'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              bookingHistoryData['booking_details'][0]['pickup_name']+' '+bookingHistoryData['booking_details'][0]['route_name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                Text(bookingHistoryData['booking_details'][0]['booking_date']),
                Text(
                  bookingHistoryData['booking_details'][0]['travel_status'],
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children:  [
                Text('Vehicle No : ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(bookingHistoryData['booking_details'][0]['bus_detail']['reg_no'], style: TextStyle(color: Colors.blue)),
              ],
            ),
            Row(
              children:  [
                Text('Vehicle Name : ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(bookingHistoryData['booking_details'][0]['bus_detail']['name'], style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            Visibility(
              visible: isExpanded!=true,
              child: InkWell(
                onTap: () {
                  setState(() {
                    isExpanded=true;
                  });
                },
                child: const Center(
                  child: Icon(Icons.keyboard_arrow_down),
                ),
              ),
            ),
            Visibility(
              visible: isExpanded,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Time and bus icon row
                    Container(
                      color: Color(0xFFF5F5F5), // Light gray background
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:  [
                          Text(
                            bookingHistoryData['booking_details'][0]['start_time'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            children: [
                              Icon(Icons.directions_bus,
                                  size: 28, color: Colors.blue),
                              SizedBox(height: 4),
                              Text(
                                "00:05 hr",
                                style:
                                TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          Text(
                            bookingHistoryData['booking_details'][0]['drop_time'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Trip details
                    buildDetailRow("Seat No", bookingHistoryData['booking_details'][0]['seat_nos']),
                    buildDetailRow("Passenger", "1"),
                    buildDetailRow("PNR No", bookingHistoryData['booking_details'][0]['pnr_no']),
                    buildDetailRow("Total Fare", '₹'+bookingHistoryData['amount']),
                    const SizedBox(height: 8),

                    const Text(
                      "You can download invoice after trip is completed.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Visibility(
                      visible: isExpanded,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isExpanded=false;
                          });
                        },
                        child: const Center(
                          child: Icon(Icons.keyboard_arrow_up),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _actionButton(String label, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }


  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}