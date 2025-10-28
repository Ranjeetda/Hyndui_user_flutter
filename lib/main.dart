import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:lmm_user/provider/booking_history_provider.dart';
import 'package:lmm_user/provider/bus_seat_provider.dart';
import 'package:lmm_user/provider/create_booking_provider.dart';
import 'package:lmm_user/provider/fare_generate_seat.dart';
import 'package:lmm_user/provider/help_support_provider.dart';
import 'package:lmm_user/provider/load_chat_provider.dart';
import 'package:lmm_user/provider/mytripes_provider.dart';
import 'package:lmm_user/provider/payment_pay_provider.dart';
import 'package:lmm_user/provider/profile_fetch_provider.dart';
import 'package:lmm_user/provider/refresh_token_provider.dart';
import 'package:lmm_user/provider/register_user_provider.dart';
import 'package:lmm_user/provider/route_explore_provider.dart';
import 'package:lmm_user/provider/route_search_provider.dart';
import 'package:lmm_user/provider/send_chat_provider.dart';
import 'package:lmm_user/provider/suggest_create_provider.dart';
import 'package:lmm_user/provider/user_default_booking_provider.dart';
import 'package:lmm_user/provider/user_update_provider.dart';
import 'package:lmm_user/provider/verify_register_user_provider.dart';
import 'package:lmm_user/resource/app_colors.dart';
import 'package:lmm_user/resource/pref_utils.dart';
import 'package:lmm_user/resource/shared_preferences.dart';
import 'package:lmm_user/ui/splash/splash_screen.dart';
import 'package:provider/provider.dart';

/// ---------------------------------------------------------------------------
/// 🔔 Background Message Handler
/// ---------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  showFlutterNotification(message);
  print('Handling a background message ${message.messageId}');
}

/// ---------------------------------------------------------------------------
/// 🔔 Local Notification Setup
/// ---------------------------------------------------------------------------
late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) return;

  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  if (message.data != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      message.data.hashCode,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data['link'],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 🔧 Device Info Helpers
/// ---------------------------------------------------------------------------
Future<String> getDeviceInfo() async {
  final deviceInfoPlugin = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    return 'Android - ${androidInfo.manufacturer} ${androidInfo.model} (${androidInfo.version.release})';
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
    return 'iOS - ${iosInfo.name} ${iosInfo.systemVersion} (${iosInfo.utsname.machine})';
  } else {
    return 'Unknown Platform';
  }
}

String getDeviceType() {
  if (Platform.isAndroid) {
    PrefUtils.setDeviceType('1');
    return 'android';
  } else if (Platform.isIOS) {
    PrefUtils.setDeviceType('2');
    return 'ios';
  } else {
    return 'unknown';
  }
}

/// ---------------------------------------------------------------------------
/// 🔑 Get FCM Token (with APNS support on iOS)
/// ---------------------------------------------------------------------------
Future<void> getToken() async {
  final messaging = FirebaseMessaging.instance;

  if (Platform.isIOS) {
    // Request iOS permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('🔕 Notifications not authorized on iOS');
      return;
    }

    // Wait for APNS token
    String? apnsToken = await messaging.getAPNSToken();
    print('📱 APNS Token: $apnsToken');
  }

  // Now safely get FCM token
  String? fcmToken = await messaging.getToken();
  if (fcmToken != null) {
    PrefUtils.setFcmToken(fcmToken);
    print('🔥 FCM Token: $fcmToken');
  }

  // Store device info
  String deviceInfo = await getDeviceInfo();
  getDeviceType();
  PrefUtils.setDeviceInfo(deviceInfo);

  print('📲 Device Info: $deviceInfo');
}

/// ---------------------------------------------------------------------------
/// 🧩 Initialization
/// ---------------------------------------------------------------------------
Future<void> init() async {
  await Prefs.init();
}

/// ---------------------------------------------------------------------------
/// 🏁 MAIN ENTRY POINT
/// ---------------------------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await setupFlutterNotifications();
  await init();

  // Wait until permissions and APNS token ready (iOS safe)
  await getToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegisterUserProvider()),
        ChangeNotifierProvider(create: (_) => VerifyRegisterUserProvider()),
        ChangeNotifierProvider(create: (_) => ProfileUpdateProvider()),
        ChangeNotifierProvider(create: (_) => ProfileFetchProvider()),
        ChangeNotifierProvider(create: (_) => BookingHistoryProvider()),
        ChangeNotifierProvider(create: (_) => RouteExploreProvider()),
        ChangeNotifierProvider(create: (_) => HelpSupportProvider()),
        ChangeNotifierProvider(create: (_) => SuggestCreateProvider()),
        ChangeNotifierProvider(create: (_) => RouteSearchProvider()),
        ChangeNotifierProvider(create: (_) => BusSeatProvider()),
        ChangeNotifierProvider(create: (_) => FareGenerateSeat()),
        ChangeNotifierProvider(create: (_) => UserDefaultBookingProvider()),
        ChangeNotifierProvider(create: (_) => CreateBookingProvider()),
        ChangeNotifierProvider(create: (_) => PaymentPayProvider()),
        ChangeNotifierProvider(create: (_) => LoadChatProvider()),
        ChangeNotifierProvider(create: (_) => SendChatProvider()),
        ChangeNotifierProvider(create: (_) => MytripesProvider()),
        ChangeNotifierProvider(create: (_) => RefreshTokenProvider()),
      ],
      child: MyApp(),
    ),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryColor,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

/// ---------------------------------------------------------------------------
/// 🧭 ROOT APP WIDGET
/// ---------------------------------------------------------------------------
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        fontFamily: 'Nunito',
        primarySwatch: Colors.teal,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
