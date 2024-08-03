import 'dart:async';
import 'dart:convert';
// import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xwatch/controllers/fitness_controller.dart';

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final prefs = await SharedPreferences.getInstance();

  prefs.reload();

  service.on('stop').listen((event) {
    service.stopSelf();
    debugPrint('background process is now stopped');
  });

  service.on('start').listen((event) {
    debugPrint("service on start");
  });

  service.on('stop').listen((event) {
    debugPrint("service on stop");
  });

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Timer.periodic(const Duration(minutes: 5), (timer) async {
  //   /* sync detail */
    
  // });

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    /* action plan */
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final Map<String, dynamic> auth = jsonDecode(prefs.getString("auth") ?? "{}");
      debugPrint("background auth: $auth, ${ auth.isNotEmpty}");
      if (auth.isNotEmpty == true) {
        debugPrint("start background... ${DateFormat("yyyy MM dd HH:mm:ss").format(DateTime.now())}");
        FitnessController fitnessController = FitnessController();
        Map<String, dynamic>? resultLog = await fitnessController.loadData();
        // debugPrint("background service resultLog: $resultLog");
        if (resultLog['error'] == false) {
          service.invoke(
            'update-log-xwatch',
            {
              "error": false,
              "error_message": "",
              "logUpdate": DateFormat("HH:mm").format(DateTime.now()),
              "resultDeviceInfo": resultLog["resultDeviceInfo"],
              "resultSleep": resultLog["resultSleep"],
              "resultHeart": resultLog["resultHeart"],
              "resultStep": resultLog["resultStep"],
            },
          );
        }
        else {
          service.invoke(
            'update-log-xwatch',
            {
              "error": true,
              "error_message": resultLog["error_message"],
              "logUpdate": DateFormat("HH:mm").format(DateTime.now()),
              "resultDeviceInfo": null,
              "resultSleep": null,
              "resultHeart": null,
              "resultStep": null,
            },
          );
        }
      }
      // service.invoke(
      //   'update-log-xwatch',
      //   {
      //     "error": false,
      //     "error_message": "",
      //     "logUpdate": DateFormat("HH:mm").format(DateTime.now()),
      //     "resultDeviceInfo": null,
      //     "resultSleep": null,
      //     "resultHeart": null,
      //     "resultStep": null,
      //   },
      // );
    } catch (e) {
      service.invoke(
        'update-log-xwatch',
        {
          "error": true,
          "error_message": "",
          "logUpdate": DateFormat("HH:mm").format(DateTime.now()),
        },
      );
    }
  });
}

class BackgroundService {
  static final BackgroundService instance = BackgroundService._internal();
  factory BackgroundService() {
    return instance;
  }
  BackgroundService._internal();

  void start() {
    final service = FlutterBackgroundService();
    service.startService();
  }

  void stop() {
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        onStart: onStart,
        isForegroundMode: true,
        autoStartOnBoot: true,
      ),
    );

  }
}
