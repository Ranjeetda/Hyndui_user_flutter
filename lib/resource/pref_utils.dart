import 'package:lmm_user/resource/shared_preferences.dart';

class PrefUtils {

  static String? setLoggedIn(bool isTrue) {
    Prefs.prefs!.setBool('isLogin', isTrue);
  }

  static bool isLoggedIn() {
    bool? isLogin = Prefs.prefs?.getBool('isLogin');
    return isLogin ?? false;
  }



  static String? setIsCheckedOffice(bool isTrue) {
    Prefs.prefs!.setBool('IsCheckedOffice', isTrue);
  }

  static bool IsCheckedOffice() {
    bool? isLogin = Prefs.prefs?.getBool('IsCheckedOffice');
    return isLogin ?? false;
  }

  static void setFcmToken(String token) {
    Prefs.prefs!.setString("token", token);
  }

  static String getFcmToken() {
    final String? value = Prefs.prefs!.getString("token");
    return value ?? '';
  }

  static void setCsrfToken(String token) {
    Prefs.prefs!.setString("csrfToken", token);
  }

  static String? getCsrfToken() {
    final String? value = Prefs.prefs!.getString("csrfToken");
    return value ?? '';
  }

  static void setBearerToken(String token) {
    Prefs.prefs!.setString("Bearer", token);
  }

  static String? getBearerToken() {
    final String? value = Prefs.prefs!.getString("Bearer");
    return value ?? '';
  }

  static String? setDeviceInfo(String deviceInfo) {
    Prefs.prefs!.setString("deviceInfo", deviceInfo);
  }

  static String getDeviceInfo() {
    final String? value = Prefs.prefs!.getString("deviceInfo");
    return value ?? '';
  }


  static String? setDeviceType(String deviceType) {
    Prefs.prefs!.setString("deviceType", deviceType);
  }

  static String getDeviceType() {
    final String? value = Prefs.prefs!.getString("deviceType");
    return value ?? '';
  }

  static String? setPhoneNo(String phonenNo) {
    Prefs.prefs!.setString("phonenNo", phonenNo);
    return null;
  }

  static String getPhone() {
    final String? value = Prefs.prefs!.getString("phonenNo");
    return value ?? '';
  }

  static String? setEmail(String email) {
    Prefs.prefs!.setString("email", email);
    return null;
  }

  static String getEmail() {
    final String? value = Prefs.prefs!.getString("email");
    return value ?? '';
  }

  static String? setGender(String gender) {
    Prefs.prefs!.setString("gender", gender);
    return null;
  }

  static String getGender() {
    final String? value = Prefs.prefs!.getString("gender");
    return value ?? '';
  }


  static String? setUserName(String userName) {
    Prefs.prefs!.setString("userName", userName);
    return null;
  }

  static String getuserName() {
    final String? value = Prefs.prefs!.getString("userName");
    return value ?? '';
  }


  static String? setUserId(String userId) {
    Prefs.prefs!.setString("userId", userId);
    return null;
  }

  static String getUserId() {
    final String? value = Prefs.prefs!.getString("userId");
    return value ?? '';
  }



  static double? setUserLat(double userLat) {
    Prefs.prefs!.setDouble("USER_LATITUDE", userLat);
    return null;
  }

  static double getUserLat() {
    final double? value = Prefs.prefs!.getDouble("USER_LATITUDE");
    return value ?? 0.0;
  }

  static double? setUserLang(double userLang) {
    Prefs.prefs!.setDouble("USER_LONGITUDE", userLang);
    return null;
  }

  static double getUserLang() {
    final double? value = Prefs.prefs!.getDouble("USER_LONGITUDE");
    return value ?? 0.0;
  }


  static String? setCurrentCity(String city) {
    Prefs.prefs!.setString("city", city);
    return null;
  }

  static String getCurrentCity() {
    final String? value = Prefs.prefs!.getString("city");
    return value ?? '';
  }

  static String? setCurrentState(String state) {
    Prefs.prefs!.setString("state", state);
    return null;
  }

  static String getCurrentState() {
    final String? value = Prefs.prefs!.getString("state");
    return value ?? '';
  }


  static bool? setProfileEmpty(bool ProfileEmpty) {
    Prefs.prefs!.setBool("ProfileEmpty", ProfileEmpty);
    return null;
  }

  static bool getProfileEmpty() {
    final bool? value = Prefs.prefs!.getBool("ProfileEmpty");
    return value ?? false;
  }

  static String? setPickupLat(String picklat) {
    Prefs.prefs!.setString("picklat", picklat);
    return null;
  }

  static String getPickupLat() {
    final String? value = Prefs.prefs!.getString("picklat");
    return value ?? '';
  }

  static String? setPickupLan(String picklan) {
    Prefs.prefs!.setString("picklan", picklan);
    return null;
  }

  static String getPickupLan() {
    final String? value = Prefs.prefs!.getString("picklan");
    return value ?? '';
  }

  static String? setPickupAddress(String pickupAddress) {
    Prefs.prefs!.setString("pickupAddress", pickupAddress);
    return null;
  }

  static String getPickupAddress() {
    final String? value = Prefs.prefs!.getString("pickupAddress");
    return value ?? '';
  }

  static String? setOfficePickupAdd(String pickupName) {
    Prefs.prefs!.setString("OFFICE_PICKUP_ADD", pickupName);
    return null;
  }

  static String getOfficePickupAdd() {
    final String? value = Prefs.prefs!.getString("OFFICE_PICKUP_ADD");
    return value ?? '';
  }
  static String? setOfficeDropAdd(String dropName) {
    Prefs.prefs!.setString("OFFICE_DROP_ADD", dropName);
    return null;
  }

  static String getOfficeDropAdd() {
    final String? value = Prefs.prefs!.getString("OFFICE_DROP_ADD");
    return value ?? '';
  }

  static String? setOfficeBookingDate(String createdDate) {
    Prefs.prefs!.setString("OFFICE_BOOKING_DATE", createdDate);
    return null;
  }

  static String getOfficeBookingDate() {
    final String? value = Prefs.prefs!.getString("OFFICE_BOOKING_DATE");
    return value ?? '';
  }

  static String? setOfficePickupTime(String pickupTime) {
    Prefs.prefs!.setString("OFFICE_PICKUP_TIME", pickupTime);
    return null;
  }

  static String getOfficePickupTime() {
    final String? value = Prefs.prefs!.getString("OFFICE_PICKUP_TIME");
    return value ?? '';
  }

  static String? setOfficeDropTime(String dropTime) {
    Prefs.prefs!.setString("OFFICE_DROP_TIME", dropTime);
    return null;
  }

  static String getOfficeDropTime() {
    final String? value = Prefs.prefs!.getString("OFFICE_DROP_TIME");
    return value ?? '';
  }

  static String? setOfficeBusName(String busName) {
    Prefs.prefs!.setString("OFFICE_BUS_NAME", busName);
    return null;
  }

  static String getOfficeBusName() {
    final String? value = Prefs.prefs!.getString("OFFICE_BUS_NAME");
    return value ?? '';
  }

  static String? setWalletBalance(String userWalletAmount) {
    Prefs.prefs!.setString("WALLET_BALANCE", userWalletAmount);
    return null;
  }

  static String getWalletBalance() {
    final String? value = Prefs.prefs!.getString("WALLET_BALANCE");
    return value ?? '';
  }


  static bool? setTheme(bool theme) {
    Prefs.prefs!.setBool("theme", theme);
  }

  static bool? getTheme() {
    final bool? value = Prefs.prefs!.getBool("theme");
    return value;
  }


  static Future<void> clearPreferences() async {
    if (Prefs.prefs != null) {
      await Prefs.prefs!.clear();  // Clear preferences
      print("Preferences cleared successfully.");
    } else {
      print("Error: SharedPreferences instance is null.");
    }
  }
}

