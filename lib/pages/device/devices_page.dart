import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:xwatch/pages/auth/login_page.dart';
import 'package:xwatch/services/background_service.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  late Map<String, dynamic> auth = {};
  late Map<String, dynamic> deviceInfo = {};
  bool isForegroundMode = true;
  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
  final MaterialStateProperty<Color?> trackColor =
        MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        // Track color when the switch is selected.
        if (states.contains(MaterialState.selected)) {
          return Colors.green;
        }
        // Otherwise return null to set default track color
        // for remaining states such as when the switch is
        // hovered, focused, or disabled.
        return null;
      },
    );

  @override
  void initState() {
    super.initState();
    getSharePreference();
    debugPrint("okeee");
  }

  Future<void> getSharePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      auth = jsonDecode(prefs.getString("auth") ?? "{}");
      deviceInfo = jsonDecode(prefs.getString("device_info") ?? "{}");
    });
    debugPrint("auth: $auth");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: ListView(
        // padding: EdgeInsets.all(12.sp),
        addAutomaticKeepAlives: true,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
            dense: true,
            leading: Icon(Icons.account_box, size: 48.sp, color: Colors.green,),
            title: Text("Akun Terdaftar", style: GoogleFonts.lora(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.sp,),
                Text("NIK ${auth['nik']}", style: GoogleFonts.lora(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  // color: Colors.blueGrey
                ),),
                SizedBox(height: 8.sp,),
                Text("Nama Lengkap \n${auth['fullname']}", style: GoogleFonts.lora(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  // color: Colors.blueGrey
                ),),
                SizedBox(height: 8.sp,),
                Text("Model \n${auth['model']}", style: GoogleFonts.lora(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  // color: Colors.blueGrey
                ),),
                SizedBox(height: 8.sp,),
                Text("Nomor Seri \n${auth['serialNo']}", style: GoogleFonts.lora(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  // color: Colors.blueGrey
                ),),
                SizedBox(height: 8.sp,),
                Text("Versi Aplikasi \n1.0.0", style: GoogleFonts.lora(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  // color: Colors.blueGrey
                ),),
              ],
            ),
          ),
          const Divider(
            height: 1,
            // height: 12, // tinggi garis pemisah
            thickness: .5, // ketebalan garis pemisah
            color: Colors.blueGrey, // warna garis pemisah
            // indent: 8, // jarak indent dari kiri
            // endIndent: 8, // jarak indent dari kanan
          ),
          // SizedBox(height: 12.sp,),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
            leading: Icon(Icons.watch_rounded, size: 48.sp, color: Colors.blue,),
            title: Text("Perangkat Smartwatch", style: GoogleFonts.lora(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 8.sp,),
                Text("Nama Perangkat \n${deviceInfo['device_name']}", style: GoogleFonts.lora(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  // color: Colors.blueGrey
                ),),
                SizedBox(height: 8.sp,),
                Text("Model \n${deviceInfo['model']}", style: GoogleFonts.lora(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  // color: Colors.blueGrey
                ),),
                SizedBox(height: 8.sp,),
                Text("No Seri \n${deviceInfo['sn']}", style: GoogleFonts.lora(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  // color: Colors.blueGrey
                ),),
              ],
            ),
          ),
          const Divider(
            height: 1,
            // height: 12, // tinggi garis pemisah
            thickness: .5, // ketebalan garis pemisah
            color: Colors.blueGrey, // warna garis pemisah
            // indent: 8, // jarak indent dari kiri
            // endIndent: 8, // jarak indent dari kanan
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
            leading: Icon(Icons.miscellaneous_services, size: 48.sp, color: Colors.orange,),
            title: Text("Background Process", style: GoogleFonts.lora(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),),
            trailing:  Switch(
              trackColor: trackColor,
              thumbIcon: thumbIcon,
              value: isForegroundMode,
              onChanged: (bool value) {
                setState(() {
                  isForegroundMode = value;
                });
                if (isForegroundMode) {
                  BackgroundService().start();
                } else {
                  BackgroundService().stop();
                }
              },
            ),
          ),
          SizedBox(height: 12.sp,),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.sp),
            margin: EdgeInsets.symmetric(horizontal: 24.sp),
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () async {
                SharedPreferences preferences = await SharedPreferences.getInstance();
                await preferences.clear();

                PersistentNavBarNavigator.pushNewScreen(
                    // ignore: use_build_context_synchronously
                    context,
                    screen: const LoginPage(),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red),
              ), 
              child: Text("Keluar", style: GoogleFonts.lora(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),),
            ),
          ),
          SizedBox(height: 72.sp,)
        ],
      ),
    );
  }
}