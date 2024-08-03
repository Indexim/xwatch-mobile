import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:xwatch/controllers/fitness_controller.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  FitnessController fitnessController = FitnessController();
  String logUpdated = DateFormat("dd MMM yy, HH:mm").format(DateTime.now());
  late String path;
  String contentFile = "";
  String messageFinish = "";
  Map<String, dynamic>? resultLog = {};
  Map<String, dynamic>? resultHeart = {};
  Map<String, dynamic>? resultSleep = {};
  Map<String, dynamic>? resultStep = {};
  Map<String, dynamic>? resultDeviceInfo = {};
  Map<String, dynamic>? auth = {};

  String errorResult = "";
  
  @override
  void initState() {
    // checkPermission();
    super.initState();
    // checkPermission();
    refreshData();
  }

  void refreshData() async {
    setState(() {
      messageFinish = "proses sinkronisasi";
    });
    resultLog = await fitnessController.loadData();
    if (resultLog!["error"] == false) {
      resultStep = resultLog!["resultStep"];
      resultHeart = resultLog!["resultHeart"];
      resultSleep = resultLog!["resultSleep"];
      resultDeviceInfo = resultLog!["resultDeviceInfo"];
      setState(() {
        messageFinish = "Data diperbaharui: $logUpdated";
      });
    }
    else {
      setState(() {
        messageFinish = "Data gagal diperbaharui: $logUpdated";
      });
    }    
  }

  void setPreference(data) async {
    final prefs = await SharedPreferences.getInstance();
    String encodeDevice = jsonEncode(data);
    await prefs.setString('device_info', encodeDevice);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () async {
          refreshData();
        },
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: FlutterBackgroundService().on('update-log-xwatch'),
          builder: (context, snapshot) {
            // debugPrint("====> receive snapshot data: ${snapshot.data}");
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final data = snapshot.data;
            // debugPrint("data background $data");
            if (data!["error"] == false) {
              errorResult = data["error_message"];
              resultDeviceInfo = data["resultDeviceInfo"];
              resultSleep = data["resultSleep"];
              resultHeart = data["resultHeart"];
              resultStep =  data["resultStep"];
              messageFinish = "Data diperbaharui $logUpdated";

              setPreference(resultDeviceInfo);
              
              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.sp),
                children: [
                  SizedBox(height: 12.sp,),
                  Text(messageFinish, style: GoogleFonts.arimo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900]
                  ),),
                  SizedBox(height: 12.sp,),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            // side: const BorderSide(color: Colors.blue, width: 2,),
                          ),
                          elevation: 0,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Flex(
                                  direction: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue[700],
                                      radius: 24.sp,
                                      child: Icon(
                                        Icons.airline_seat_individual_suite_rounded,
                                        color: Colors.white,
                                        size: 28.sp,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text("Lelap:      \n ${resultSleep != null ? "${int.tryParse(resultSleep!["totalDeepSleepTime"].toString().substring(0,2)).toString()} jam, ${int.tryParse(resultSleep!["totalDeepSleepTime"].toString().substring(3, 5)).toString()} menit" : "0 Jam"}", style: GoogleFonts.arimo(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[900]
                                        ),),
                                        Text("Ringan:     \n ${resultSleep != null ? "${int.tryParse(resultSleep!["totalLightDurationTime"].toString().substring(0,2)).toString()} jam, ${int.tryParse(resultSleep!["totalLightDurationTime"].toString().substring(3, 5)).toString()} menit" : "0 Jam"}", style: GoogleFonts.arimo(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[400]
                                        ),),
                                      ],
                                    ),
                                  ],
                                ),                          
                                SizedBox(height: 18.sp),
                                Text(resultSleep != null ? "${int.tryParse(resultSleep!["totalDurationTime"].toString().substring(0,2)).toString()} jam, ${int.tryParse(resultSleep!["totalDurationTime"].toString().substring(3, 5)).toString()} menit" 
                                  : "0 Jam", style: TextStyle(
                                  fontSize: 12.sp, color: Colors.black87
                                )),
                                Text(DateFormat("dd MMM").format(DateTime.now()), style: TextStyle(
                                    fontSize: 12.sp, color: Colors.grey[700]
                                )),
                                SizedBox(height: 8.sp),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.sp,),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            // side: const BorderSide(color: Colors.blue, width: 2,),
                          ),
                          elevation: 0,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.pink[400],
                                  radius: 24.sp,
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                ),                          
                                SizedBox(height: 18.sp),
                                Text(resultHeart != null ? "${resultHeart!["hr"]} BPM" : "0 BPM", style: TextStyle(
                                    fontSize: 12.sp, color: Colors.black87
                                )),
                                Text(DateFormat("dd MMM").format(DateTime.now()), style: TextStyle(
                                    fontSize: 12.sp, color: Colors.grey[700]
                                )),
                                SizedBox(height: 8.sp),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            // side: const BorderSide(color: Colors.blue, width: 2,),
                          ),
                          elevation: 0,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 24.sp,
                                  child: Icon(
                                    Icons.directions_walk,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                ),                          
                                SizedBox(height: 18.sp),
                                Text(resultStep != null ? "${resultStep!["steps"]} langkah" : "0 langkah", style: TextStyle(
                                    fontSize: 12.sp, color: Colors.black87
                                )),
                                Text(DateFormat("dd MMM").format(DateTime.now()), style: TextStyle(
                                    fontSize: 12.sp, color: Colors.grey[700]
                                )),
                                SizedBox(height: 8.sp),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.sp,),
                ],
              );
            } else {
              resultDeviceInfo = null;
              resultSleep = null;
              resultHeart = null;
              resultStep =  null;
              messageFinish = "Error ${data['error_message']}";
              
              return ListView(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.sp),
                    child: Column(
                      children: [
                        Text("Error $messageFinish", style: GoogleFonts.rubik(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.red
                        ),),
                        // ElevatedButton(
                        //   onPressed: () async {
                        //     // checkPermission();
                        //     // await _getStoragePermission();
                        //     // PermissionDevice permissionDevice = PermissionDevice();
                        //     // final permission = await permissionDevice.storagePermission();
                        //     // debugPrint('permission : $permission');
                        //     // await _getStoragePermission();
                        //   }, 
                        //   child: const Text('Request Storage Permission')),
                      ],
                    ),
                  )
                ],
              );
            }
          }
        )
      ),
    );
  }
}