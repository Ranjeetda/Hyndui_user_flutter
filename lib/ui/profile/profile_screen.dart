import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lmm_user/resource/image_paths.dart';
import 'package:lmm_user/resource/pref_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:place_picker_google/place_picker_google.dart';
import 'package:provider/provider.dart';

import '../../provider/profile_fetch_provider.dart';
import '../../provider/user_update_provider.dart';
import '../../resource/Utils.dart';
import '../../resource/app_colors.dart';
import '../google_map_screen/google_maps.dart';
import '../model/LocationModel.dart';
import '../model/SocialLoginUserDetails.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _number1Controller = TextEditingController();
  final TextEditingController _number2Controller = TextEditingController();
  final TextEditingController _number3Controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String googleApikey = "AIzaSyD0oY8U_-sWgRRiaOC-U7_TAf0iSZGUHow";
  SocialLoginUserDetails? socialLoginUserDetails;
  String? _selectedTimeHome;
  String? _selectedTimeOffice;
  int isSelected = 0;
  String? selectedGender;
  String? mHomeAddress;
  String? mOfficeAddress;
  double? mHomeLat;
  double? mHomeLang;
  double? mOfficeLat;
  double? mOfficeLang;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> requestPermissionsn() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();

    statuses.forEach((permission, status) {
      print('$permission: $status');
    });

    if (statuses.values.any((status) => status != PermissionStatus.granted)) {
      print("Not all permissions granted!");
    } else {
      print("All permissions granted!");
      _showPickerDialog();
    }
  }

  void _showPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> setTimeForRide({required bool forHome}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      int hour = pickedTime.hour;
      int minute = pickedTime.minute;

      String timeSet = '';
      int displayHour = hour;

      if (hour > 12) {
        displayHour = hour - 12;
        timeSet = 'PM';
      } else if (hour == 0) {
        displayHour = 12;
        timeSet = 'AM';
      } else if (hour == 12) {
        timeSet = 'PM';
      } else {
        timeSet = 'AM';
      }

      final String minStr = minute < 10 ? '0$minute' : '$minute';
      final String formattedTime = '$displayHour:$minStr $timeSet';

      setState(() {
        if (forHome) {
          _selectedTimeHome = formattedTime;
        } else {
          _selectedTimeOffice = formattedTime;
        }
      });
    }
  }


  Widget _buildDivider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Divider(color: Color(0xFFCCCCCC), thickness: 1),
      );

  Widget _buildLabelText(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF666666),
          fontFamily: 'GoogleSansRegular',
        ),
      );

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF666666),
        fontFamily: 'GoogleSansRegular',
      ),
    );
  }

  Widget _buildTextFieldOther({
    required String hint,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF666666),
        fontFamily: 'GoogleSansRegular',
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'GoogleSansRegular',
        fontSize: 16,
        color: Color(0xFF666666),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.2),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    bool isTime = false,
    double labelFlex = 1.5,
    double valueFlex = 4,
    Color? valueColor,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: labelFlex.round(),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'GoogleSansRegular',
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            flex: valueFlex.round(),
            child: Text(
              value.isNotEmpty ? value : (hint ?? ''),
              style: TextStyle(
                fontFamily: 'GoogleSansRegular',
                fontSize: 16,
                color: valueColor ?? const Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getProfileUser() async {
    final response =
        await Provider.of<ProfileFetchProvider>(context, listen: false)
            .fetchProfile();
    var responseData = json.decode(response.body);
    setState(() {
      isLoading = false;
    });
    if (responseData['status'] == true) {
      _firstNameController.text = responseData['data']['firstname'];
      _lastNameController.text = responseData['data']['lastname'];
      _companyController.text = responseData['data']['company'];
      _employeeCodeController.text = responseData['data']['customer_code'];
      selectedGender = responseData['data']['gender'];
      _emailController.text = responseData['data']['email'];
      _phoneController.text = responseData['data']['phone'];
      _number1Controller.text = responseData['data']['emargency_number1'];
      _number2Controller.text = responseData['data']['emargency_number2'];
      _number3Controller.text = responseData['data']['emargency_number3'];

      mHomeAddress = responseData['data']['home_address'];
      mHomeLat = responseData['data']['home_lat'];
      mHomeLang = responseData['data']['home_lng'];

      mOfficeAddress = responseData['data']['office_address'];
      mOfficeLat = responseData['data']['office_lat'];
      mOfficeLang = responseData['data']['office_lng'];

      mHomeAddress = responseData['data']['home_address'].toString().isNotEmpty
          ? responseData['data']['home_address']
          : 'Home address';
      _selectedTimeHome =
          responseData['data']['home_timing'].toString().isNotEmpty
              ? responseData['data']['home_timing']
              : '0.00';
      mOfficeAddress =
          responseData['data']['office_address'].toString().isNotEmpty
              ? responseData['data']['office_address']
              : 'Office address';
      _selectedTimeOffice =
          responseData['data']['office_timing'].toString().isNotEmpty
              ? responseData['data']['office_timing']
              : '0.00';
    } else {
      setState(() {
        isLoading = false;
      });
      var errorData = json.decode(response.body);
      String errorMessage =
          errorData['message'] ?? 'Profile fetch in failed. Please try again.';
      Utils.showErrorMessage(context, errorMessage);
    }
  }


  void updateUserProfile() async {
    setState(() => isLoading = true);
    try {
      final response = await ProfileUpdateProvider().updateInformation(
        file: _image,
        firstname: _firstNameController.text,
        lastname: _lastNameController.text,
        gender: selectedGender!,
        email: _emailController.text,
        companyName: _companyController.text,
        employeeCode: _employeeCodeController.text,
        number1: _number1Controller.text,
        number2: _number2Controller.text,
        number3: _number3Controller.text,
        referedby: '',
        deviceToken: PrefUtils.getFcmToken(),
        officeAddress: mOfficeAddress!,
        officeLat: mOfficeLat.toString(),
        officeLng: mOfficeLang.toString(),
        homeAddress: mHomeAddress!,
        homeLat: mHomeLat.toString(),
        homeLng: mHomeLang.toString(),
        homeLeaveTime: _selectedTimeHome!,
        officeLeaveTime: _selectedTimeOffice!,
        socialId: '',
        mode: '',
        isRegisteredWithSocial: false,
      );

      setState(() => isLoading = false);
      print('Response: $response');

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${response['body'] ?? response['error']}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }


  @override
  initState() {
    super.initState();
    _getProfileUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            // Back arrow icon
            onPressed: () {
              Navigator.pop(context); // Go back to the previous screen
            },
          ),
          title: Text(
            "Edit Profile",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Color(0xFF023E8A),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    requestPermissionsn();
                  },
                  child: SizedBox(
                    height: 140, // Adjust based on your content
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// Profile Image
                        Positioned(
                          top: 24,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _image != null
                                ? FileImage(
                                    _image!) // <- FileImage when user picked an image
                                : AssetImage(ImagePaths.profile)
                                    as ImageProvider,
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),

                        /// Add/Edit Icon
                        Positioned(
                          top: 100,
                          child: Container(
                            padding: const EdgeInsets.all(6), // spacing_6dp
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white, // bg_circle
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              ImagePaths.pencil,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Edit Your Personal Details',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF333333),
                              fontFamily: 'GoogleSansBold',
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// First Name
                        Row(
                          children: [
                            Expanded(
                                flex: 3, child: _buildLabelText('First Name')),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 7,
                                child: _buildTextField(
                                    'Enter first name', _firstNameController)),
                          ],
                        ),

                        _buildDivider(),

                        /// Last Name
                        Row(
                          children: [
                            Expanded(
                                flex: 3, child: _buildLabelText('Last Name')),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 7,
                                child: _buildTextField(
                                    'Enter last name', _lastNameController)),
                          ],
                        ),

                        _buildDivider(),

                        /// Company Name
                        Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: _buildLabelText('Company Name')),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 7,
                                child: _buildTextField(
                                    'Company Name', _companyController)),
                          ],
                        ),

                        _buildDivider(),

                        /// Employee Code
                        Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: _buildLabelText('Employee Code')),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 7,
                                child: _buildTextField(
                                    'Employee Code', _employeeCodeController)),
                          ],
                        ),

                        _buildDivider(),

                        /// Gender Dropdown
                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildLabelText('Gender')),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 7,
                              child: DropdownButtonFormField<String>(
                                value: selectedGender,
                                items: genderOptions
                                    .map((gender) => DropdownMenuItem(
                                          value: gender,
                                          child: Text(
                                            gender,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'GoogleSansRegular',
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Edit Your Contact',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF333333),
                              fontFamily: 'GoogleSansBold',
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// Email
                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildLabelText('Email')),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 7,
                              child: _buildTextFieldOther(
                                hint: 'Enter email',
                                controller: _emailController,
                                inputType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),

                        _buildDivider(),

                        /// Phone
                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildLabelText('Phone')),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 7,
                              child: _buildTextFieldOther(
                                hint: 'Enter phone number',
                                controller: _phoneController,
                                inputType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(15)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 4,
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Emergency Contact',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'GoogleSansBold',
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            TextField(
                              controller: _number1Controller,
                              keyboardType: TextInputType.number,
                              decoration:
                                  _buildInputDecoration('Enter your number1'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _number2Controller,
                              keyboardType: TextInputType.number,
                              decoration:
                                  _buildInputDecoration('Enter your number2'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _number3Controller,
                              keyboardType: TextInputType.number,
                              decoration:
                                  _buildInputDecoration('Enter your number3'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 4,
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 8.0, top: 12, bottom: 8),
                          child: Text(
                            'Enter Your Places',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'GoogleSansBold',
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),

                        /// Home Address Row

                        InkWell(
                          onTap: () async {
                            _openPlacePicker(true);
                          },
                          child: _buildRow(
                            label: 'Home',
                            value: '',
                            hint: mHomeAddress ?? 'Home address',
                          ),
                        ),

                        /// Home Leave Time Row
                        InkWell(
                          onTap: () {
                            setTimeForRide(forHome: true);
                          },
                          child: _buildRow(
                            label: 'Time you leave from home',
                            value: _selectedTimeHome == null
                                ? "0:00"
                                : _selectedTimeHome!,
                            labelFlex: 4,
                            valueFlex: 1.5,
                            valueColor: Color(0xFF1A237E), // colorPrimaryDark
                          ),
                        ),

                        const Divider(
                          height: 32,
                          thickness: 1,
                          color: Color(0xFFE0E0E0),
                          // view_color
                          indent: 16,
                          endIndent: 16,
                        ),

                        /// Office Address Row
                        InkWell(
                          onTap: () async {
                            _openPlacePicker(false);
                          },
                          child: _buildRow(
                            label: 'Office',
                            value: '',
                            hint: mOfficeAddress ?? 'Office address',
                          ),
                        ),

                        /// Office Leave Time Row
                        InkWell(
                          onTap: () {
                            setTimeForRide(forHome: false);
                          },
                          child: _buildRow(
                            label: 'Time you leave from office',
                            value: _selectedTimeOffice == null
                                ? "0:00"
                                : _selectedTimeOffice!,
                            labelFlex: 4,
                            valueFlex: 1.5,
                            valueColor: Color(0xFF1A237E), // colorPrimaryDark
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateUserProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'TitilliumWeb',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ));
  }

  void _openPlacePicker(bool mHome) async {
    LocationResult? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: googleApikey,
          onPlacePicked: (LocationResult result) {
            Navigator.of(context).pop(result); // Return result to the calling function
          },
        ),
      ),
    );

    if (result == null) {
      print("User canceled or an error occurred");
      return;
    }

    print("Place Selected: ${result.formattedAddress}");
    print("Latitude: ${result.latLng?.latitude}, Longitude: ${result.latLng?.longitude}");

    setState(() {
      final subLocality = result.subLocalityLevel1?.longName;
      if (mHome) {
        mHomeAddress = subLocality;
        mHomeLat = result.latLng?.latitude;
        mHomeLang = result.latLng?.longitude;
      } else {
        mOfficeAddress = subLocality;
        mOfficeLat = result.latLng?.latitude;
        mOfficeLang = result.latLng?.longitude;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Location Confirmed: ${result.formattedAddress}")),
    );
  }

}
