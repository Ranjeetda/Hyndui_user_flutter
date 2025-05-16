import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lmm_user/resource/pref_utils.dart';
import 'app_colors.dart';


class Utils {
  static BuildContext? _loaderContext;
  static late BuildContext _loadingDialoContext;
  static bool _isLoaderShowing = false;
  static bool _isLoadingDialogShowing = false;
  static late Timer toastTimer;

//  Checks
  static bool isNotEmpty(String s) {
    return s != null && s.trim().isNotEmpty;
  }

  static bool isEmpty(String s) {
    return !isNotEmpty(s);
  }

  static bool isListNotEmpty(List<dynamic> list) {
    return list != null && list.isNotEmpty;
  }

  //  Views
  static void showToast1(BuildContext context, String message) {
    showCustomToast(context, message);
  }

  static void showSuccessMessage(BuildContext context, String message) {
    showCustomToast(context, message, bgColor: AppColors.snackBarGreen);
  }

  static void showNeutralMessage(BuildContext context, String message) {
    showCustomToast(context, message, bgColor: AppColors.snackBarColor);
  }

  static void showErrorMessage(BuildContext context, String message) {
    showCustomToast(context, message, bgColor: AppColors.snackBarRed);
  }

  static void showValidationMessage(BuildContext context, String message) {
    showCustomToast(context, message);
  }

  static void showCustomToast(BuildContext context, String message,
      {Color bgColor = AppColors.primaryColor}) {
    showToast(message,
        context: context,
        fullWidth: true,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14,color: Colors.white),
        animation: StyledToastAnimation.slideFromTopFade,
        reverseAnimation: StyledToastAnimation.slideToTopFade,
        position:
        const StyledToastPosition(align: Alignment.topCenter, offset: 0.0),
        startOffset: const Offset(0.0, -3.0),
        backgroundColor: bgColor,
        reverseEndOffset: const Offset(0.0, -3.0),
        duration: const Duration(seconds: 3),
        animDuration: const Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
  }

  static void showErrorToast(BuildContext context, String message,
      {Color bgColor = AppColors.snackBarRed}) {
    showToast(message,
        context: context,
        fullWidth: true,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        animation: StyledToastAnimation.slideFromTopFade,
        reverseAnimation: StyledToastAnimation.slideToTopFade,
        position:
        const StyledToastPosition(align: Alignment.topCenter, offset: 0.0),
        startOffset: const Offset(0.0, -3.0),
        backgroundColor: AppColors.snackBarRed,
        reverseEndOffset: const Offset(0.0, -3.0),
        duration: const Duration(seconds: 3),
        animDuration: const Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
  }

  static void showLoader(BuildContext context) {
    if (!_isLoaderShowing) {
      _isLoaderShowing = true;
      _loaderContext ??= context;
      showDialog(
          context: _loaderContext!,
          barrierDismissible: false,
          builder: (_loaderContext) {
            return const SpinKitSpinningLines(
              size: 30,
              color: AppColors.primaryColor,
            );
          });
    }
  }

  static Widget buildLoader() {
    return const SpinKitSpinningLines(
      size: 80,
      color: AppColors.primaryColor,
    );
  }


  static void hideLoader() {
    if (_isLoaderShowing) {
      Navigator.pop(_loaderContext!);
      _loaderContext ??= null;
    }
  }

  static void showLoadingDialog(BuildContext context) {
    if (!_isLoadingDialogShowing) {
      _isLoadingDialogShowing = true;
      _loadingDialoContext = context;
      showDialog(
          context: _loadingDialoContext,
          barrierDismissible: false,
          builder: (context) {
            return const SpinKitSpinningLines(
              color: AppColors.primaryColor,
            );
          })
          .then((value) => {
        _isLoadingDialogShowing = false,
        print('LoadingDialog hidden!')
      });
    }
  }


  static void hideLoadingDialog() {
    if (_isLoadingDialogShowing) {
      Navigator.pop(_loadingDialoContext);
      _loadingDialoContext == null;
    }
  }

  static void hideKeyBoard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static ThemeData getAppThemeData() {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      canvasColor: Colors.transparent,
      brightness: Brightness.light,
    );
  }


  static String convertTimeToBeautify(DateTime time) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(time);
  }

  static String calculateNext3rdDate(DateTime departDate) {
    try {
      final DateTime thirdDay = departDate.add(const Duration(days: 3));
      final DateFormat formatter = DateFormat('yyyy-MM-dd'); // Matches YEAR_MONTH_DAY_FORMATTER
      return formatter.format(thirdDay);
    } catch (e) {
      debugPrint('calculateNext3rdDate: Error=${e.toString()}');
      return 'N/A';
    }
  }

  static String convertDateToBeautify(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date.toLocal()); // Ensure it's local time
  }

  static String splitString(String value){
    String input = value;
    String result = input.split(',')[0].trim();
    return result;
  }

  static String diffTime(String time1, String time2) {
    String totalHours = "";

    try {
      final format = DateFormat("HH:mm");

      final date1 = format.parse(time1);
      final date2 = format.parse(time2);

      Duration difference = date2.difference(date1);

      // If time2 is earlier than time1, the difference will be negative.
      // So we take absolute value to match the Kotlin logic.
      difference = difference.abs();

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      totalHours =
      "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} hr";
    } catch (e) {
      print("Error parsing time: $e");
    }

    return totalHours;
  }

  static String convertDateToBeautifyString(String putDate) {
    try {
      final inputFormat = DateFormat("yyyy-MM-dd");
      final outputFormat = DateFormat("EEE, d MMM yyyy");
      final date = inputFormat.parse(putDate);
      return outputFormat.format(date);
    } catch (e) {
      print("convertDateToBeautify: Error=${e.toString()}");
      return "--------";
    }
  }

  static Future<void> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      var _currentAddress = "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

      PrefUtils.setCurrentCity(place.locality.toString());
      PrefUtils.setCurrentState(place.administrativeArea.toString());

      print('Address: $_currentAddress');
    } catch (e) {
      print('Error getting address: $e');
    }
  }
}
