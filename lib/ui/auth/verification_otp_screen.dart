import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lmm_user/resource/Utils.dart';
import 'package:lmm_user/resource/app_colors.dart';
import 'package:lmm_user/resource/image_paths.dart';
import 'package:lmm_user/resource/pref_utils.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../provider/verify_register_user_provider.dart';
import '../navigation_screen/bottom_navigation_bar.dart';
import 'package:http/http.dart' as http;

class VerificationOtpScreen extends StatefulWidget {
  String _verificationId;

  VerificationOtpScreen(this._verificationId);

  @override
  _VerificationOtpScreen createState() => _VerificationOtpScreen();
}

class _VerificationOtpScreen extends State<VerificationOtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? mOtp;
  bool isLoading = false;

  void _verifyOTP() async {
    setState(() => isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget._verificationId!,
        smsCode: mOtp!,
      );

      await _auth.signInWithCredential(credential);
      setState(() => isLoading = false);
      _verifyUser(mOtp!, true);
    } catch (e) {
      _verifyUser(mOtp!, false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to verify OTP: $e")),
      );
    }
  }

  Future<void> _verifyUser(String Otp, bool isMobileVerified) async {

    http.Response response =
        await Provider.of<VerifyRegisterUserProvider>(context, listen: false)
            .sendVeryUserRequestService(
                PrefUtils.getFcmToken(),
                PrefUtils.getDeviceType(),
                Otp,
                isMobileVerified,
                PrefUtils.getDeviceInfo());

    var responseData = json.decode(response.body);

    if (responseData['status'] == true) {
      checkUserDetails(responseData['userDetail']);
    } else {
      setState(() {
        isLoading = false;
      });
      var errorData = json.decode(response.body);
      String errorMessage =
          errorData['message'] ?? 'Sign in failed. Please try again.';
      Utils.showErrorMessage(context, errorMessage);
    }
  }

  void checkUserDetails(var responseData) {
    if (responseData != null) {
      setState(() => isLoading = false);
      if (responseData['firstname'].toString().isNotEmpty &&
          responseData['lastname'].toString().isNotEmpty &&
          responseData['email'].toString().isNotEmpty) {
        PrefUtils.setLoggedIn(true);
        PrefUtils.setPhoneNo(responseData['phone']);
        PrefUtils.setEmail(responseData['email']);
        PrefUtils.setGender(responseData['gender']);
        PrefUtils.setUserName(responseData['firstname'] + responseData['lastname']);
        PrefUtils.setProfileEmpty(true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomBottomNavigationBar(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone login successful!")),
        );
      } else {
        setState(() => isLoading = false);
        PrefUtils.setLoggedIn(true);
        PrefUtils.setProfileEmpty(false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomBottomNavigationBar(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone login successful!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text(
            'Verification',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'CustomFont',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            // Custom back arrow
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Image.asset(
                    ImagePaths.mobileOtp,
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  const Text(
                    'Enter you verification code \n we have just sent you on your mobile number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (value) {
                      mOtp = value;
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8.0),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeColor: AppColors.primaryColor,
                      inactiveColor: Colors.grey.shade300,
                      selectedColor: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (mOtp != null&&mOtp!.length==6) {
                            _verifyOTP();
                          } else {
                            Utils.showErrorToast(
                                context, "Please enter your otp");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : const Row(
                          children: [
                            Text(
                              'Verify',
                              style: TextStyle(
                                  fontSize: 16, color: AppColors.white),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
