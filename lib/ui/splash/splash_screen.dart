import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lmm_user/resource/app_colors.dart';
import 'package:page_transition/page_transition.dart';
import '../../resource/image_paths.dart';
import '../../resource/pref_utils.dart';
import '../navigation_screen/bottom_navigation_bar.dart';
import '../selection_screen/selection_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var splashDuration = 2000;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
    startCountdownTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                ImagePaths.appLogo,
                width: 100.0,
                height: 100.0,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              'Developed by HYUNDAI',
              style: TextStyle(fontSize: 16.0), // Replace with appropriate font size
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<Timer> startCountdownTimer() async {
    final _duration = Duration(milliseconds: splashDuration);
    return Timer(_duration, navigateToPage);
  }

  Future<void> navigateToPage() async {


    if(PrefUtils.isLoggedIn()){
      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
              child: CustomBottomNavigationBar(),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 900),
              reverseDuration: (const Duration(milliseconds: 900))),
              (Route<dynamic> route) => false);
    }else{
      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
              child: SelectionScreen(),
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 900),
              reverseDuration: (const Duration(milliseconds: 900))),
              (Route<dynamic> route) => false);
    }
  }

  
}
