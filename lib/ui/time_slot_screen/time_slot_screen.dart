import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/route_search_provider.dart';
import '../../resource/Utils.dart';
import '../../resource/app_colors.dart';
import '../select_seat_screen/select_seat_screen.dart';

class TimeSlotScreen extends StatefulWidget {
  String? currentDate = '';
  String? currentTime = '';
  String? endDate = '';

  String? bookingType = "";
  String? has_return = "";

  var officeAddress = "";
  var officeLat = "";
  var officeLng = "";

  var homeAddress = "";
  var homeLat = "";
  var homeLng = "";
  var pickStopUpId = "";
  var dropStopId = "";

  var homeLeaveTime = "";
  var officeLeaveTime = "";

  TimeSlotScreen(
      this.currentDate,
      this.currentTime,
      this.endDate,
      this.bookingType,
      this.has_return,
      this.officeAddress,
      this.officeLat,
      this.officeLng,
      this.homeAddress,
      this.homeLat,
      this.homeLng,
      this.pickStopUpId,
      this.dropStopId,
      this.homeLeaveTime,
      this.officeLeaveTime);

  @override
  State<TimeSlotScreen> createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends State<TimeSlotScreen> {
  var mTotalVehicle = "";

  DateTime _selectedDate = DateTime.now();

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));

      String formattedDate = Utils.convertDateToBeautify(_selectedDate);
      searchRouts(formattedDate, '00:00', widget.endDate!);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchRouts(widget.currentDate!, '00:00', widget.endDate!);
    });
  }

  Future<void> searchRouts(
      String currentDate, String currentTime, String endDate) async {
    Utils.showLoadingDialog(context);
    final response =
        await Provider.of<RouteSearchProvider>(context, listen: false)
            .sendSearchRootRequestService(
                widget.homeLat,
                widget.homeLng,
                widget.officeLat,
                widget.officeLng,
                currentDate,
                currentTime,
                endDate,
                widget.bookingType!,
                widget.pickStopUpId,
                widget.dropStopId,
                widget.has_return!);
    var responseData = json.decode(response.body);

    print("Response Search Root ===========> ${response.body}");
    if (responseData['status'] == true) {
      setState(() {
        mTotalVehicle = responseData['data']['getnearestData'].length.toString();
      });
      Utils.hideLoadingDialog();
    } else {
      Utils.hideLoadingDialog();
      var errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ??
          'Search Root fetch in failed. Please try again.';
      Utils.showErrorMessage(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd - MMM - yyyy').format(_selectedDate);

    return Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            // Back arrow icon
            onPressed: () {
              Navigator.pop(context); // Go back to the previous screen
            },
          ),
          title: Text(
            "Select a time slot",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date Picker
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      _changeDate(-1);
                    },
                    child: Icon(Icons.arrow_back_ios, size: 18),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    onTap: () {
                      _changeDate(1);
                    },
                    child: Icon(Icons.arrow_forward_ios, size: 18),
                  ),
                ],
              ),
            ),

            Text(
              "$mTotalVehicle Vehicle Available",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Vehicle Card
            Consumer<RouteSearchProvider>(
              builder: (context, provider, _) {
                if (provider.rootData.isEmpty) {
                  return Center(child: Utils.buildLoader());
                } else {
                  return Expanded(
                    flex: 1,
                    child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: provider.rootData['status']
                          ? provider.rootData['data']['getnearestData'].length
                          : 0,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              String routeId = provider.rootData['data']
                                  ['getnearestData'][index]['routeId'];
                              String route_timetableId =
                                  provider.rootData['data']['getnearestData']
                                      [index]['busScheduleId'];
                              String busId = provider.rootData['data']
                                  ['getnearestData'][index]['route_busId'];
                              String pickupId = provider.rootData['data']
                                  ['getnearestData'][index]['pickup_stop_id'];
                              String dropId = provider.rootData['data']
                                  ['getnearestData'][index]['drop_stop_id'];
                              String stops = provider.rootData['data']
                                      ['getnearestData'][index]
                                      ['total_of_stops']
                                  .toString();
                              String bookingType = widget.bookingType!;
                              String has_return = widget.has_return!;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectSeatScreen(
                                        routeId,
                                        route_timetableId,
                                        busId,
                                        pickupId,
                                        dropId,
                                        stops,
                                        bookingType,
                                        has_return,
                                        widget.currentDate!,
                                        widget.endDate!)),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // LMM User tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A2D5F),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "LMM User",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Time & route
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          provider.rootData['data']
                                                  ['getnearestData'][index]
                                              ['pickup_stop_departure_time'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      const Icon(Icons.directions_bus,
                                          color: Colors.blue),
                                      Column(
                                        children: [
                                          Text('ETA',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0A2D5F),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              Utils.diffTime(
                                                  provider.rootData['data']
                                                              ['getnearestData']
                                                          [index][
                                                      'pickup_stop_arrival_time'],
                                                  provider.rootData['data']
                                                              ['getnearestData']
                                                          [index][
                                                      'drop_stop_arrival_time']),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                              provider.rootData['data']
                                                          ['getnearestData']
                                                          [index]
                                                          ['total_of_stops']
                                                      .toString() +
                                                  'Stops',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                      const Icon(Icons.directions_bus,
                                          color: Colors.blue),
                                      Text(
                                          provider.rootData['data']
                                                  ['getnearestData'][index]
                                              ['drop_stop_arrival_time'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Location info and route link
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${provider.rootData['data']['getnearestData'][index]['pickup_stop_name']}  to  ${provider.rootData['data']['getnearestData'][index]['drop_stop_name']}",
                                          style: TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "View Route",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ));
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ));
  }
}
