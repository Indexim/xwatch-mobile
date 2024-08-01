import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:xwatch/pages/auth/login_page.dart';
import 'package:xwatch/pages/dashboard/dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.title});
  final String title;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  
  
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    final prefs = await SharedPreferences.getInstance();
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    // FlutterNativeSplash.remove();
    
    if (prefs.getString("auth") != null) {
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
        (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 16.h,),
              Image.asset(
                'assets/icons/PT-Indexim-Coalindo.png',
                width: 48.w,
              ),
              SizedBox(height: 18.sp,),
              Text(
                "X-Watch",
                style: GoogleFonts.rubik(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900]
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}