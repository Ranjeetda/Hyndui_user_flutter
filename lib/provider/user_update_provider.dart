import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lmm_user/provider/URLS.dart';
import 'package:lmm_user/resource/pref_utils.dart';

class ProfileUpdateProvider with ChangeNotifier {
  Future<Map<String, dynamic>> updateInformation({
    required File? file,
    required String firstname,
    required String lastname,
    required String gender,
    required String email,
    required String companyName,
    required String employeeCode,
    required String number1,
    required String number2,
    required String number3,
    required String referedby,
    required String deviceToken,
    required String officeAddress,
    required String officeLat,
    required String officeLng,
    required String homeAddress,
    required String homeLat,
    required String homeLng,
    required String homeLeaveTime,
    required String officeLeaveTime,
    required String socialId,
    required String mode,
    required bool isRegisteredWithSocial,
  }) async {
    final url = Uri.parse(URLS.userProfileUpdate);

    try {
      print("RanjeetTest Authorization ============> "+PrefUtils.getBearerToken()!);
      print("RanjeetTest firstname ============> "+firstname);
      print("RanjeetTest lastname ============> "+lastname);
      print("RanjeetTest gender ============> "+gender);
      print("RanjeetTest email ============> "+email);
      print("RanjeetTest company ============> "+companyName);
      print("RanjeetTest employee_code ============> "+employeeCode);
      print("RanjeetTest emargency_number1 ============> "+number1);
      print("RanjeetTest emargency_number2 ============> "+number2);
      print("RanjeetTest emargency_number3 ============> "+number3);
      print("RanjeetTest referedby ============> "+referedby);
      print("RanjeetTest device_token ============> "+deviceToken);
      print("RanjeetTest office_lat ============> "+officeLat);
      print("RanjeetTest office_lng ============> "+officeLng);
      print("RanjeetTest home_address ============> "+homeAddress);
      print("RanjeetTest home_lat ============> "+homeLat);
      print("RanjeetTest home_lng ============> "+homeLng);
      print("RanjeetTest home_timing ============> "+homeLeaveTime);
      print("RanjeetTest office_timing ============> "+officeLeaveTime);
      print("RanjeetTest social_id ============> "+socialId);
      print("RanjeetTest mode ============> "+mode);
      
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = PrefUtils.getBearerToken()!;
      request.fields['firstname'] = firstname;
      request.fields['lastname'] = lastname;
      request.fields['gender'] = gender;
      request.fields['email'] = email;
      request.fields['company'] = companyName;
      request.fields['employee_code'] = employeeCode;
      request.fields['emargency_number1'] = number1;
      request.fields['emargency_number2'] = number2;
      request.fields['emargency_number3'] = number3;
      request.fields['referedby'] = referedby;
      request.fields['device_token'] = deviceToken;
      request.fields['office_address'] = officeAddress;
      request.fields['office_lat'] = officeLat;
      request.fields['office_lng'] = officeLng;
      request.fields['home_address'] = homeAddress;
      request.fields['home_lat'] = homeLat;
      request.fields['home_lng'] = homeLng;
      request.fields['home_timing'] = homeLeaveTime;
      request.fields['office_timing'] = officeLeaveTime;
      if (isRegisteredWithSocial) {
        request.fields['social_id'] = socialId;
        request.fields['mode'] = mode;
      } else {
        request.fields['social_id'] = '';
        request.fields['mode'] = '';
      }

      if (file != null) {
        var filePart = await http.MultipartFile.fromPath(
          'ProfilePic',
          file.path,
          contentType: MediaType('image', 'png'),
        );
        request.files.add(filePart);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('User updated successfully');
        return json.decode(responseBody);
      } else {
        print('Failed to update user: ${response.statusCode}');
        print('Response body: $responseBody');
        return {
          'success': false,
          'status': response.statusCode,
          'body': responseBody,
        };
      }
    } catch (error) {
      print('Error occurred: $error');
      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }
}
