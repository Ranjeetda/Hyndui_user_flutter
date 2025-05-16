
class URLS {
  //static const String baseUrl = "https://dev.happiesttravel.com/api/"; // Your api url
  static const  String baseUrl = "https://stg.happiesttravel.com/api/"; // Your api url

  static const String baseProfileImageUrl = 'https://hrms.flexichain.in/uploads/profile_images/';
  static const String SIGN_IN_URL = '${baseUrl}users/register';
  static const String verifyUser = '${baseUrl}users/verify';
  static const String userProfileUpdate = '${baseUrl}users/updateuser';
  static const String profileFetch = '${baseUrl}users/me';
  static const String bookingHistory = '${baseUrl}users/booking-transactions';
  static const String routeExplore = '${baseUrl}routes/explore';
  static const String suggestCreate = '${baseUrl}suggest/create';
  static const String routeSearch = '${baseUrl}routes/route-search';
  static const String busesSeat = '${baseUrl}buses/';
  static const String fareGenerateSeat = '${baseUrl}fare/generate-seat-fare';
  static const String userDefaultBooking = '${baseUrl}users/default-booking';
  static const String bookingCreate = baseUrl+'booking/create';
  static const String paymentPay = '${baseUrl}payments/pay';
  static const String postChat = '${baseUrl}chat/';
  static const String loadChat = '${baseUrl}chat/get';

  static const String EMPLOYEE_DEPARTMENT_CONTACT_LIST_URL = baseUrl+'employee/employee-department-contact-list?';
  static const String EMPLOYEE_AWARD_LIST_URL = baseUrl+'employee/employee-award-list';
  static const String EMPLOYEE_ATTENDANCE_LIST_URL = '${baseUrl}employee/employee-attendance-list?';
  static const String employeeFilterAttendanceListUrl = '${baseUrl}employee/employee-attendance-list-params';
  static const String EMPLOYEE_ATTENDANCE_TIME_LIST_URL = '${baseUrl}employee/employee-attendance-time?';
  static const String EMPLOYEE_POST_NOTIFICATION_STATUS_URL = '${baseUrl}employee/employee-post-notification-status';
  static const String EMPLOYEE_MARK_ATTENDANCE_URL = '${baseUrl}employee/employee-mark-attendance?';
  static const String EMPLOYEE_ATTENDANCE_TIME_URL = '$baseUrl/employee/employee-attendance-time?';
  static const String EMPLOYEE_LEAVE_DETAIL_URL = '${baseUrl}employee/employee-leave-detail?leaveId=7';
  static const String EMPLOYEE_PROFILE_DATA_URL = '${baseUrl}employee/employee-profile-data';
  static const String EMPLOYEE_NOTICEBOARD_LIST_URL = '${baseUrl}employee/employee-noticeboard-list?';
  static const String EMPLOYEE_LEAVE_LIST_URL = '${baseUrl}employee/employee-leave-list?';
  static const String EMPLOYEE_TYPE_EXPENSE_URL = '${baseUrl}employee/employee-type-of-expense-list?';
  static const String EMPLOYEE_TYPE_EXPENSE_FIELDS_URL = '${baseUrl}employee/employee-type-of-expense-fields?typeOfExpense=';
}