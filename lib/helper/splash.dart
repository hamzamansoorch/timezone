import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:time_zone/main.dart';
import 'timezone_helper.dart'; // Ensure this import matches the path to your ContactListPage

class SplashScreen extends StatefulWidget {
  final TimezoneHelper timezoneHelper; // Add this

  SplashScreen({required this.timezoneHelper}); // Add this

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade, // You can use other transitions like PageTransitionType.leftToRight
        child: ContactListPage(timezoneHelper: widget.timezoneHelper), // Pass the timezoneHelper
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/earthclock.png', fit: BoxFit.cover), // Replace with your splash image
      ),
    );
  }
}
