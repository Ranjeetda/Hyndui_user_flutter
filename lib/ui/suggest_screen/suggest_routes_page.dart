import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:lmm_user/resource/app_colors.dart';
import 'package:place_picker_google/place_picker_google.dart';

import '../../provider/suggest_create_provider.dart';


class SuggestRoutesPage extends StatefulWidget {
  @override
  _SuggestRoutesPageState createState() => _SuggestRoutesPageState();
}

class _SuggestRoutesPageState extends State<SuggestRoutesPage> {
  late GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  String googleApikey = "AIzaSyD0oY8U_-sWgRRiaOC-U7_TAf0iSZGUHow";
  String location = "Search Location";
  Marker? _pickupMarker;
  Marker? _dropoffMarker;
  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;

  String? pickup_address;
  double? pickup_lat;
  double? pickup_lng;
  String? pickup_city;
  String? pickup_state;

  String? drop_address;
  double? drop_lat;
  double? drop_lng;
  String? drop_city;
  String? drop_state;
  bool isLoading = false;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};


  void _handleMapTap(LatLng position) {
    if (_pickupLatLng == null) {
      _setLocation(position, isPickup: true);
    } else if (_dropoffLatLng == null) {
      _setLocation(position, isPickup: false);
    } else {
      // Reset both if already selected
      setState(() {
        _pickupLatLng = null;
        _dropoffLatLng = null;
        _markers.clear();
        _polylines.clear();
      });
      _setLocation(position, isPickup: true);
    }
  }

  void _setLocation(LatLng position, {required bool isPickup}) {
    setState(() {
      if (isPickup) {
        _pickupLatLng = position;
        _pickupMarker = Marker(
          markerId: MarkerId("pickup"),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: "Pick-up"),
        );
      } else {
        _dropoffLatLng = position;
        _dropoffMarker = Marker(
          markerId: MarkerId("dropoff"),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: "Drop-off"),
        );
      }

      _markers
        ..clear()
        ..addAll([
          if (_pickupMarker != null) _pickupMarker!,
          if (_dropoffMarker != null) _dropoffMarker!,
        ]);
    });
  }

  Future<void> _drawRoute() async {
    if (_pickupLatLng == null || _dropoffLatLng == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(_pickupLatLng!.latitude, _pickupLatLng!.longitude),
        destination: PointLatLng(_dropoffLatLng!.latitude, _dropoffLatLng!.longitude),
        mode: TravelMode.driving,
      ),
    );


    if (result.points.isNotEmpty) {
      final List<LatLng> polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ));
      });
    }
  }

  Future<Map<String, String?>> getCityStateFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return {
          'city': placemark.locality,
          'state': placemark.administrativeArea,
        };
      }
    } catch (e) {
      print("Error in geocoding: $e");
    }
    return {'city': null, 'state': null};
  }

  void _openPlacePicker(bool isPickup) async {

    LocationResult? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          onPlacePicked: (LocationResult result) async {
            print("Place Selected: ${result.formattedAddress}");
            print("Latitude: ${result.latLng?.latitude}, Longitude: ${result.latLng?.longitude}");


            if (result != null) {
              final lat = result.latLng?.latitude;
              final lang = result.latLng?.longitude;
              var newlatlang = LatLng(lat!, lang!);

              mapController.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: newlatlang, zoom: 17)));

              final placeDetails = await getCityStateFromLatLng(lat, lang);


              setState(() {
                location = result.formattedAddress!;
                if(isPickup) {
                  _setLocation(newlatlang, isPickup: isPickup);
                  pickup_address = result.formattedAddress!;
                  pickup_lat =result.latLng?.latitude;
                  pickup_lng =result.latLng?.longitude;
                  pickup_city = placeDetails['city'];
                  pickup_state = placeDetails['state'];
                  _pickupLatLng=newlatlang;
                }else{
                  _setLocation(newlatlang, isPickup: isPickup);
                  drop_address = result.formattedAddress!;
                  drop_lat =result.latLng?.latitude;
                  drop_lng=result.latLng?.longitude;
                  drop_city = placeDetails['city'];
                  drop_state = placeDetails['state'];
                  _dropoffLatLng =newlatlang;
                }
                _drawRoute();
              });

            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Location Confirmed: ${result.formattedAddress}")),
            );

            Navigator.of(context).pop(); // Close Place Picker after confirmation
          }, apiKey: googleApikey,
        ),
      ),
    );

    if (result == null) {
      print("User canceled or an error occurred");
      return;
    }
  }

  void updateUserProfile() async {
    setState(() => isLoading = true);
    try {
      final response = await SuggestCreateProvider().sendSuggestRootRequestService(
        pickup_address!,
        pickup_lat.toString(),
        pickup_lng.toString(),
        drop_address!,
        drop_lat.toString(),
        drop_lng.toString(),
        pickup_city.toString(),
        pickup_state.toString(),
        drop_city.toString(),
        drop_state!
      );
      setState(() => isLoading = false);
      print('Response: $response');

      Navigator.of(context).pop();
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text(
          "Suggest Route",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Card(
                  margin: EdgeInsets.only(top: 20),
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (controller) {
                          mapController = controller;
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(37.7749, -122.4194),
                          zoom: 10.0,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        onTap: (position) {
                          _handleMapTap(position);
                        },
                      ),
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:AppColors.primaryColor, // Use bg_btn_shape or colorPrimary
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text(
                            "Submit",
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 130,
            child:  Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Icons and Dotted Line
                    Column(
                      children: [
                        // Top Icon (Pick-up circle)
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(0xFF002B5B), // Dark blue
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Dotted Line
                        Container(
                          width: 2,
                          height: 32,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.grey,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  return Container(
                                    width: 2,
                                    height: 2,
                                    color: Colors.grey,
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        // Bottom Icon (Drop-off map pin)
                        Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF002B5B),
                          size: 20,
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // Right Text Labels
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: ()  {
                              _openPlacePicker(true);
                            },
                            child: Text(
                              pickup_address??'Pick-up Location',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          const Divider(height: 24),
                          InkWell(
                            onTap: ()  {
                              _openPlacePicker(false);
                            },
                            child: Text(
                              drop_address??'Drop-off Location',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}