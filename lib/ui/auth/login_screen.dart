import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lmm_user/provider/register_user_provider.dart';
import 'package:lmm_user/resource/Utils.dart';
import 'package:lmm_user/resource/image_paths.dart';
import 'package:lmm_user/ui/auth/verification_otp_screen.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../resource/app_colors.dart';
import '../../resource/pref_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  String? _verificationId;
  String? mMobileNumber;
  String? mCountryCode = '+91';
  String? countryDetail = '';
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void _sendOTP() async {
    setState(() => isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '$mCountryCode$mMobileNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Auto sign-in complete")),
          );
          setState(() => isLoading = false);
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage;

          if (e.code == 'invalid-phone-number') {
            errorMessage = "The phone number is not valid.";
          } else if (e.code == 'too-many-requests') {
            errorMessage = "Too many attempts. Please try again later.";
          } else {
            errorMessage = "Verification failed: ${e.message}";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          setState(() => isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationOtpScreen(_verificationId!),
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("OTP sent")),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          setState(() => isLoading = false);
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    }
  }


  Future<void> _registerUser() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      if (mCountryCode!.isEmpty) {
        Utils.showErrorMessage(context, 'Please select country code.');
        return;
      } else if (_phoneController.text.isEmpty) {
        Utils.showErrorMessage(context, 'Please enter mobile number');
        return;
      }
      http.Response response =
          await Provider.of<RegisterUserProvider>(context,
          listen: false)
          .sendRequestService(mCountryCode!, _phoneController.text,PrefUtils.getFcmToken(),
           countryDetail!,'en');


      var responseData = json.decode(response.body);
      setState(() {
        isLoading = false;
      });
      if (responseData['status'] == true) {
         PrefUtils.setCsrfToken(responseData['csrfToken']);
         PrefUtils.setBearerToken('Bearer ${responseData['token']}');
         _sendOTP();
      } else {
        setState(() {
          isLoading = false;
        });
        var errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ??'Sign in failed. Please try again.';
        Utils.showErrorMessage(context, errorMessage);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Center everything on the screen
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // Center items vertically
              crossAxisAlignment: CrossAxisAlignment.center,
              // Center items horizontally
              children: [
                Image.asset(
                  ImagePaths.appLogo,
                  height: 150,
                ),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          // Add a blue border
                          color: AppColors.primaryColor,
                          // Change this to your preferred shade of blue
                          width: 2.0, // Adjust border thickness if needed
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CountryCodePicker(
                            initialSelection: 'IN',
                            favorite: ['+91', 'IN'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            onChanged: (country) {
                              mCountryCode = country.dialCode;
                              Map<String, dynamic> countryObj = {
                                'country_name': country.name,
                                'country_with_plus': country.dialCode,
                                'country_name_code': country.code,
                                'country_code': country.dialCode?.replaceAll('+', ''),
                              };

                              print(countryObj);
                              countryDetail=countryObj.toString();
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Enter phone number',
                                border: InputBorder.none,
                                prefixStyle: TextStyle(
                                    color: Colors.black, fontWeight: FontWeight.w500),
                              ),
                              onChanged: (value) {
                                mMobileNumber = value;
                                print(mMobileNumber); // full number with country code
                              },
                            ),
                          )
                        ],
                      )
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _registerUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'TitilliumWeb',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
