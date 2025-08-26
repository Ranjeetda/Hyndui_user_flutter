import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lmm_user/resource/Utils.dart';
import 'package:lmm_user/resource/pref_utils.dart';
import 'package:provider/provider.dart';

import '../../provider/fare_generate_seat.dart';
import '../../provider/profile_fetch_provider.dart';
import '../../provider/refresh_token_provider.dart';
import '../../provider/route_search_provider.dart';
import '../../provider/user_default_booking_provider.dart';
import '../../resource/app_colors.dart';
import '../confirm_payment_screen/confirm_payment_screen.dart';
import '../message_screen/chat_message.dart';
import '../profile/profile_screen.dart';
import '../time_slot_screen/time_slot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  bool isChecked = false;
  bool isCheckboxChecked = false;
  bool showMore = false;
  bool isInstantRideSelected = true;

  Position? _currentPosition;
  String? _currentAddress = '';
  DateTime now = DateTime.now();
  bool? isSwap = false;
  var responseData;

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

  // Admin booking
  var selectedSeatNo = "";
  Map<String, dynamic> _faredata = {};
  bool isLoading = false;



  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      if (mounted) _currentPosition = position;
    });

    // Save lat, long locally (if needed)
    PrefUtils.setUserLat(position.latitude);
    PrefUtils.setUserLang(position.longitude);

    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');

    // Get human-readable address
    Utils.getAddressFromLatLng(position);
  }

  Future<void> _getProfileUser() async {
    final response =
        await Provider.of<ProfileFetchProvider>(context, listen: false)
            .fetchProfile();
    responseData = json.decode(response.body);
    Utils.showLoadingDialog(context);
    if (responseData['status'] == true) {
      setState(() {
        Utils.hideLoadingDialog();
        officeAddress = responseData['data']['office_address'];
        homeAddress = responseData['data']['home_address'];
        officeLat = responseData['data']['office_lat'].toString();
        officeLng = responseData['data']['office_lng'].toString();
        homeLat = responseData['data']['home_lat'].toString();
        homeLng = responseData['data']['home_lng'].toString();
        homeLeaveTime = responseData['data']['home_timing'];
        officeLeaveTime = responseData['data']['office_timing'];
      });
    } else {
      Utils.hideLoadingDialog();
      var errorData = json.decode(response.body);
      String errorMessage =
          errorData['message'] ?? 'Profile fetch in failed. Please try again.';
      Utils.showErrorMessage(context, errorMessage);
    }
  }

  void swipeAddress() {
    try {
      setState(() {
        if (!isSwap! && responseData != null) {
          //Utils.vibratePhone();
          isSwap = true;

          homeAddress = responseData['data']['home_address'];
          officeAddress = responseData['data']['office_address'];
          homeLat = responseData['data']['home_lat'].toString();
          homeLng = responseData['data']['home_lng'].toString();
          officeLat = responseData['data']['office_lat'].toString();
          officeLng = responseData['data']['office_lng'].toString();
          officeLeaveTime = responseData['data']['office_timing'];
          homeLeaveTime = responseData['data']['home_timing'];
        } else {
          //Utils.vibratePhone();
          isSwap = false;

          officeAddress = responseData['data']['office_address'];
          homeAddress = responseData['data']['home_address'];
          officeLat = responseData['data']['office_lat'].toString();
          officeLng = responseData['data']['office_lng'].toString();
          homeLat = responseData['data']['home_lat'].toString();
          homeLng = responseData['data']['home_lng'].toString();
          homeLeaveTime = responseData['data']['home_timing'];
          officeLeaveTime = responseData['data']['office_timing'];
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  bool validateOffice({
    required String homeAddress,
    required String officeAddress,
    required String homeLeaveTime,
    required String officeLeaveTime,
    required BuildContext context,
  }) {
    bool isValid = true;

    if (homeAddress.isEmpty && officeAddress.isEmpty) {
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Home and Office addresses are required')),
      );
    } else if (homeLeaveTime.isEmpty && officeLeaveTime.isEmpty) {
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave times are required')),
      );
    }

    return isValid;
  }

  Future<void> searchRouts() async {
    Utils.showLoadingDialog(context);
    final response =
        await Provider.of<RouteSearchProvider>(context, listen: false)
            .sendSearchRootRequestService(
                homeLat,
                homeLng,
                officeLat,
                officeLng,
                currentDate!,
                currentTime!,
                endDate!,
                bookingType!,
                pickStopUpId,
                dropStopId,
                has_return!);
    var responseData = json.decode(response.body);

    print("Response Search Root ===========> ${response.body}");
    if (responseData['status'] == true) {
      Utils.hideLoadingDialog();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TimeSlotScreen(
                currentDate,
                currentTime,
                endDate,
                bookingType,
                has_return,
                officeAddress,
                officeLat,
                officeLng,
                homeAddress,
                homeLat,
                homeLng,
                pickStopUpId,
                dropStopId,
                homeLeaveTime,
                officeLeaveTime)),
      );
    } else {
      Utils.hideLoadingDialog();
      var errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ??
          'Search Root fetch in failed. Please try again.';
      Utils.showErrorMessage(context, errorMessage);
    }
  }

  Future<void> _getFareSeat(Map<String, dynamic> _userDefoultBookingData) async {
    setState(() => isLoading = true);
    has_return='1';
    try {
      final response =
      await Provider.of<FareGenerateSeat>(context, listen: false)
          .sendFareGenerateRequestService(
        _userDefoultBookingData['bookingId'][0]['busId']['_id'],
        _userDefoultBookingData['bookingId'][0]['routeId']['_id'],
        _userDefoultBookingData['bookingId'][0]['busscheduleId']['_id'],
        _userDefoultBookingData['bookingId'][0]['pickupId']['_id'],
        _userDefoultBookingData['bookingId'][0]['dropoffId']['_id'],
       _userDefoultBookingData['booking_details'][0]['seat_nos'],
        currentDate!,
        has_return!,
      );

      var responseData = json.decode(response.body);
      setState(() => isLoading = false);
      if (responseData['status'] == true) {
        if (!mounted) return;
        if (responseData['status'] == true) {
          setState(() {
            _faredata = responseData['data'];
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showBookingOptions(context);
          });
        }

      } else {
        String errorMessage = responseData['message'] ??
            'Fare data fetch failed. Please try again.';
        Utils.showErrorMessage(context, errorMessage);
      }
    } catch (e) {
      Utils.showErrorMessage(context, 'An error occurred. Please try again.');
      setState(() => isLoading = false);

    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    //PrefUtils.setBearerToken("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ3YWxsZXRJZCI6IjY3NjgzZDkxZjkxYzkzY2Q3YzI0Mjg0OCIsInVzZXJJZCI6IjY3NjgzZDkxZjkxYzkzY2Q3YzI0Mjg0MiIsImlhdCI6MTc0NjM2NjYxMiwiZXhwIjoxNzUwMjcyOTc4OTg2fQ.b8xrAqZgyBh7ouDV5Oxk-p48bZn7Au9Srd4VdOY9b5k");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserDefaultBookingProvider>(context, listen: false)
          .userDefaultBookRequestService();

    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RefreshTokenProvider>(context, listen: false)
          .refreshToken();

    });
    _getCurrentLocation();
    _getProfileUser();
    currentDate = Utils.convertDateToBeautify(now);
    currentTime = Utils.convertTimeToBeautify(now);
    endDate = Utils.calculateNext3rdDate(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              color: Color(0xFFF1F5F9),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Instant Ride Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  PrefUtils.setIsCheckedOffice(false);
                                  isInstantRideSelected = true;
                                  bookingType = 'oneway';
                                  has_return = '1';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isInstantRideSelected
                                      ? Color(0xFF023E8A)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Instant Ride",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isInstantRideSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Office Ride Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  PrefUtils.setIsCheckedOffice(true);
                                  isInstantRideSelected = false;
                                  bookingType = 'office';
                                  has_return = '1';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isInstantRideSelected
                                      ? Colors.white
                                      : Color(0xFF023E8A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Office Ride",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isInstantRideSelected
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
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
            isInstantRideSelected
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 10,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    "SH 99, Mangura, Bihar 855101...",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Icon(Icons.location_on, color: Colors.blue),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(color: Colors.grey),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_pin,
                                    color: Colors.blue),
                                const SizedBox(width: 10),
                                const Text(
                                  "Drop-off Location",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  if (validateOffice(
                                      homeAddress: homeAddress,
                                      officeAddress: officeAddress,
                                      homeLeaveTime: homeLeaveTime,
                                      officeLeaveTime: officeLeaveTime,
                                      context: context)) {
                                    searchRouts();
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProfileScreen()),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Find Route",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<UserDefaultBookingProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading) {
                            return Center(child: Utils.buildLoader());
                          } else {
                            return SizedBox(
                              height: 400,
                              child: ListView.builder(
                                padding: EdgeInsets.all(8),
                                itemCount: provider.defaultBookingList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              15, 15, 15, 0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Icon(
                                                        Icons.directions_bus,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Ride Payable Amount",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    SizedBox(height: 4),
                                                    Text(
                                                        "Mode : ${provider.defaultBookingList[index]['method']}",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                  "₹ ${provider.defaultBookingList[index]['amount']}",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              SizedBox(width: 8),
                                              Icon(Icons.check_circle_outline,
                                                  color: Colors.green),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    15, 15, 15, 0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "${provider.defaultBookingList[index]['booking_details'][0]['pickup_name']} TO ${provider.defaultBookingList[index]['booking_details'][0]['dropoff_title']}",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text("", style: TextStyle(fontSize: 14, color: Colors.green)),
                                                        isLoading
                                                            ? const CircularProgressIndicator(
                                                            color: Colors.white)
                                                            : SizedBox(
                                                          width: 120,
                                                          // Set desired width
                                                          height: 35,
                                                          // Set desired height
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              selectedSeatNo = provider.defaultBookingList[index]['booking_details'][0]['seat_nos'];
                                                              _getFareSeat(provider.defaultBookingList[index]);
                                                            },
                                                            style:
                                                            ElevatedButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                              AppColors
                                                                  .white,
                                                              shape:
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    5.0),
                                                                side: BorderSide(
                                                                    color: AppColors
                                                                        .primaryColor),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              'Book Now',
                                                              style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: AppColors
                                                                    .primaryColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    // Bus Details
                                                    _busDetailRow(
                                                        "Vehicle No:",
                                                        provider.defaultBookingList[
                                                                        index][
                                                                    'booking_details']
                                                                [
                                                                0]['bus_detail']
                                                            ['reg_no']),
                                                    _busDetailRow(
                                                        "Vehicle Name:",
                                                        provider.defaultBookingList[
                                                                        index][
                                                                    'booking_details']
                                                                [
                                                                0]['bus_detail']
                                                            ['name']),
                                                  ],
                                                )),
                                            SizedBox(height: 5),
                                            Visibility(
                                              visible: showMore == false,
                                              child: Center(
                                                child: IconButton(
                                                  icon: Icon(Icons
                                                      .keyboard_arrow_down),
                                                  onPressed: () {
                                                    setState(() {
                                                      showMore = true;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: showMore,
                                              child: Column(
                                                children: [
                                                  // Time Section
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    color: AppColors.warm_grey,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          provider.defaultBookingList[
                                                                      index][
                                                                  'booking_details']
                                                              [0]['start_time'],
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Column(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .directions_bus,
                                                                color: Colors
                                                                    .blue),
                                                            Text(
                                                              Utils.diffTime(provider.defaultBookingList[
                                                              index][
                                                              'booking_details']
                                                              [0]['start_time'],provider.defaultBookingList[
                                                              index][
                                                              'booking_details']
                                                              [0]['drop_time']),
                                                              style: TextStyle(
                                                                  fontSize: 14),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          provider.defaultBookingList[
                                                          index][
                                                          'booking_details']
                                                          [0]['drop_time'],
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                child: Text(
                                                                    "Seat No :")),
                                                            Text(": "),
                                                            Expanded(
                                                              child: Text(
                                                                provider.defaultBookingList[index]['booking_details'][0]['seat_nos'],
                                                                style: TextStyle(
                                                                    color: AppColors
                                                                        .primaryColor),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                          children: [
                                                            Checkbox(
                                                              value: isChecked,
                                                              checkColor:
                                                                  AppColors
                                                                      .white,
                                                              fillColor: MaterialStateProperty
                                                                  .all(AppColors
                                                                      .primaryColor),
                                                              onChanged: (bool?
                                                                  value) {
                                                                setState(() {
                                                                  isChecked =
                                                                      value ??
                                                                          false;
                                                                });
                                                              },
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                  "You can choose your pick location within 500 meters from your actual pickup point."),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Show Less Button
                                                  IconButton(
                                                    icon: Icon(Icons
                                                        .keyboard_arrow_up),
                                                    onPressed: () {
                                                      setState(() {
                                                        showMore = false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      )
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Pick Up Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_pin,
                                        color: Colors.green, size: 20),
                                    SizedBox(width: 5),
                                    Text("Pick Up",
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.circle,
                                        color: Colors.green, size: 14),
                                    SizedBox(width: 5),
                                    Text(
                                        isSwap!
                                            ? Utils.splitString(officeAddress)
                                            : Utils.splitString(homeAddress),
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),

                            // Space between columns and swap icon
                            SizedBox(width: 35),

                            // Swap icon
                            InkWell(
                              onTap: () {
                                swipeAddress();
                              },
                              child: Center(
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform:
                                      Matrix4.rotationY(isSwap! ? 3.1416 : 0),
                                  // flip icon horizontally
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey
                                          .shade300, // background color of the circle
                                    ),
                                    child: Icon(
                                      Icons.swap_horiz,
                                      size: 25,
                                      color: Colors.grey[800], // icon color
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Space between swap icon and Drop Off Column
                            SizedBox(width: 35),

                            // Drop Off Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_pin,
                                        color: Colors.red, size: 20),
                                    SizedBox(width: 5),
                                    Text("Drop Up",
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.circle,
                                        color: Colors.red, size: 14),
                                    SizedBox(width: 5),
                                    Text(
                                        isSwap!
                                            ? Utils.splitString(homeAddress)
                                            : Utils.splitString(officeAddress),
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    color: AppColors.primaryColor),
                                SizedBox(width: 5),
                                Text("Office Timing:",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.primaryColor)),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(homeLeaveTime,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black)),
                                Text("to", style: TextStyle(fontSize: 16)),
                                Text(officeLeaveTime,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black)),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                Checkbox(
                                  value: isChecked,
                                  checkColor: AppColors.white,
                                  fillColor: MaterialStateProperty.all(
                                      AppColors.primaryColor),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isChecked = value ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                      "You can choose your pick location within 500 meters from your actual pickup point."),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                if (validateOffice(
                                    homeAddress: homeAddress,
                                    officeAddress: officeAddress,
                                    homeLeaveTime: homeLeaveTime,
                                    officeLeaveTime: officeLeaveTime,
                                    context: context)) {
                                  searchRouts();
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen()),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                minimumSize: Size(
                                    double.infinity, 50), // Full-width button
                              ),
                              child: const Text(
                                'Find Route',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<UserDefaultBookingProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading) {
                            return Center(child: Utils.buildLoader());
                          } else {
                            return SizedBox(
                              height: 400,
                              child: ListView.builder(
                                padding: EdgeInsets.all(8),
                                itemCount: provider.defaultBookingList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              15, 15, 15, 0),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8),
                                                    ),
                                                    child: Icon(
                                                        Icons.directions_bus,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Ride Payable Amount",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold)),
                                                    SizedBox(height: 4),
                                                    Text(
                                                        "Mode : ${provider.defaultBookingList[index]['method']}",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                            Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                  "₹ ${provider.defaultBookingList[index]['amount']}",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight.bold)),
                                              SizedBox(width: 8),
                                              Icon(Icons.check_circle_outline,
                                                  color: Colors.green),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    15, 15, 15, 0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "${provider.defaultBookingList[index]['booking_details'][0]['pickup_name']} TO ${provider.defaultBookingList[index]['booking_details'][0]['dropoff_title']}",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold)),
                                                    SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Text("", style: TextStyle(fontSize: 14, color: Colors.green)),
                                                        isLoading
                                                            ? const CircularProgressIndicator(
                                                            color: Colors.white)
                                                            : SizedBox(
                                                          width: 120,
                                                          // Set desired width
                                                          height: 35,
                                                          // Set desired height
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              selectedSeatNo = provider.defaultBookingList[index]['booking_details'][0]['seat_nos'];
                                                              if(bookingType=='office'){
                                                                PrefUtils.setOfficePickupAdd(provider.defaultBookingList[index]['booking_details'][0]['pickup_name']);
                                                                PrefUtils.setOfficeDropAdd(provider.defaultBookingList[index]['booking_details'][0]['dropoff_title']);
                                                                PrefUtils.setOfficeBookingDate(provider.defaultBookingList[index]['booking_details'][0]['booking_date']);
                                                                PrefUtils.setOfficePickupTime(provider.defaultBookingList[index]['booking_details'][0]['start_time']);
                                                                PrefUtils.setOfficeDropTime(provider.defaultBookingList[index]['booking_details'][0]['drop_time']);
                                                                PrefUtils.setOfficeBusName(provider.defaultBookingList[index]['booking_details'][0]['bus_detail']['name']);
                                                               // PrefUtils.setWalletBalance(provider.defaultBookingList[index]['booking_details'][0]['user_total_wallet_amount'].toString());
                                                              }
                                                              _getFareSeat(provider.defaultBookingList[index]);
                                                            },
                                                            style:
                                                            ElevatedButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                              AppColors
                                                                  .white,
                                                              shape:
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    5.0),
                                                                side: BorderSide(
                                                                    color: AppColors
                                                                        .primaryColor),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              'Book Now',
                                                              style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: AppColors
                                                                    .primaryColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    // Bus Details
                                                    _busDetailRow(
                                                        "Vehicle No:",
                                                        provider.defaultBookingList[
                                                        index][
                                                        'booking_details']
                                                        [
                                                        0]['bus_detail']
                                                        ['reg_no']),
                                                    _busDetailRow(
                                                        "Vehicle Name:",
                                                        provider.defaultBookingList[
                                                        index][
                                                        'booking_details']
                                                        [
                                                        0]['bus_detail']
                                                        ['name']),
                                                  ],
                                                )),
                                            SizedBox(height: 5),
                                            Visibility(
                                              visible: showMore == false,
                                              child: Center(
                                                child: IconButton(
                                                  icon: Icon(Icons
                                                      .keyboard_arrow_down),
                                                  onPressed: () {
                                                    setState(() {
                                                      showMore = true;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: showMore,
                                              child: Column(
                                                children: [
                                                  // Time Section
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    color: AppColors.warm_grey,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Text(
                                                          provider.defaultBookingList[
                                                          index][
                                                          'booking_details']
                                                          [0]['start_time'],
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                        Column(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .directions_bus,
                                                                color: Colors
                                                                    .blue),
                                                            Text(
                                                              Utils.diffTime(provider.defaultBookingList[
                                                              index][
                                                              'booking_details']
                                                              [0]['start_time'],provider.defaultBookingList[
                                                              index][
                                                              'booking_details']
                                                              [0]['drop_time']

                                                              ),
                                                              style: TextStyle(
                                                                  fontSize: 14),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          provider.defaultBookingList[
                                                          index][
                                                          'booking_details']
                                                          [0]['drop_time'],
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        15),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                child: Text(
                                                                    "Seat No :")),
                                                            Text(": "),
                                                            Expanded(
                                                              child: Text(
                                                                provider.defaultBookingList[index]['booking_details'][0]['seat_nos'],
                                                                style: TextStyle(
                                                                    color: AppColors
                                                                        .primaryColor),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                          children: [
                                                            Checkbox(
                                                              value: isChecked,
                                                              checkColor:
                                                              AppColors
                                                                  .white,
                                                              fillColor: MaterialStateProperty
                                                                  .all(AppColors
                                                                  .primaryColor),
                                                              onChanged: (bool?
                                                              value) {
                                                                setState(() {
                                                                  isChecked =
                                                                      value ??
                                                                          false;
                                                                });
                                                              },
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                  "You can choose your pick location within 500 meters from your actual pickup point."),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Show Less Button
                                                  IconButton(
                                                    icon: Icon(Icons
                                                        .keyboard_arrow_up),
                                                    onPressed: () {
                                                      setState(() {
                                                        showMore = false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
            // Payment Options
          ],
        ),
      ),
    );
  }

  void _showBookingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConfirmPaymentScreen(
                        'Booking',
                        selectedSeatNo!,
                        _faredata,
                      ),
                    ),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle:  Text('Proceed to pay ₹${_faredata['final_total_fare']} for this ride',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ),
              ),
              const Divider(indent: 16, endIndent: 16, height: 1),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatMessage(
                        'Booking',
                        selectedSeatNo!,
                        _faredata,
                      ),
                    ),
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFF1F3F4),
                    radius: 20,
                    child: Icon(Icons.chat_bubble_outline, color: Colors.black87),
                  ),
                  title: Text('Chat with driver',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text('Price negotiation with driver',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _busDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 14, color: Colors.black))),
          Text(":", style: TextStyle(fontSize: 14, color: Colors.black)),
          SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor))),
        ],
      ),
    );
  }

}
