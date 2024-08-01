import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xwatch/controllers/dashboard_controller.dart';
import 'package:xwatch/controllers/device_watch.dart';
import 'package:xwatch/helper/tools.dart';

class FitnessController {
  DevicesWatch watch = DevicesWatch();
  String contentFile = "";
  DateTime now = DateTime.now();
  DateTime? twelveAM;
  String findByDatetime  = "";
  int finfByTimeStamp = 0;
  String findWord = "";
  String errorResult = "";
  LineSplitter ls = const LineSplitter();
  
  Future<Map<String, dynamic>> loadData() async {
    debugPrint("load data......");
    // final service = FlutterBackgroundService();
    // service.startService();
    // BackgroundService().start();  // sama dng atas fungsinya
    Map<String, dynamic>? resultHeart = {};
    Map<String, dynamic>? resultSleep = {};
    Map<String, dynamic>? resultStep = {};
    Map<String, dynamic>? resultDeviceInfo = {};
    
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("lastLog") == null) {
      await prefs.setString('lastLog', DateFormat("yyyyMMdd").format(DateTime.now()));
    }
    
    Map<String, dynamic>? auth = {};
    auth = jsonDecode(prefs.getString("auth") ?? "{}");
    // debugPrint("============== auth: $auth");
    
    Map<String, dynamic> resultLog =  await getLog();
    // debugPrint("resultLog: $resultLog");
    if (resultLog['error'] == false) {
      resultHeart = resultLog["resultHeart"];
      resultStep = resultLog["resultStep"];
      resultDeviceInfo = resultLog["resultDeviceInfo"];
      resultSleep = resultLog["resultSleep"];
      
      Map<String, dynamic> data = {};
      data['logUpdated'] = DateFormat("yyyy-MM-dd").format(DateTime.now());
      data['username'] = "zanurano";
      data['step'] = resultStep!["steps"] ?? 0;
      data['bpm'] = resultHeart!["hr"] ?? 0;
      data['duration_sleep'] = resultSleep!["totalDuration"] ?? 0;
      data['duration_deep_sleep'] = resultSleep["deepDuration"] ?? 0; 
      data['duration_light_sleep'] = resultSleep["lightDuration"] ?? 0;
      data['seri_no'] = resultLog["resultDeviceInfo"]!['sn'];
      data['device_id'] = resultLog["resultDeviceInfo"]!['sn'];
      data['model'] = resultDeviceInfo!['model'];
      data['nik'] = auth!['nik'];

      DashboardController dashboard = DashboardController();
      // sinkron data ke server
      // debugPrint("auth: $auth");
      // debugPrint("data: $data"); 
      if (auth['serialNo'] == data['seri_no']) {
        await dashboard.sinkronData(data, resultDeviceInfo, auth);
        return {
          "error": false,
          "error_message": "",
          "resultDeviceInfo": resultDeviceInfo,
          "resultSleep": resultSleep,
          "resultHeart": resultHeart,
          "resultStep": resultStep,
        };
      }
      else {
        return {
          "error": true,
          "error_message": "Perangkat pengguna tidak sama dengan perangkat terdaftar",
          "resultDeviceInfo": resultDeviceInfo,
          "resultSleep": resultSleep,
          "resultHeart": resultHeart,
          "resultStep": resultStep,
        };
      }
    } else {
      return {
          "error": true,
          "error_message": resultLog['error_message'],
        };
    }
    
  }

  Future<Map<String, dynamic>> getLog() async { 
    try {
      Map<String, dynamic>? resultHeart = {};
      Map<String, dynamic>? resultSleep = {};
      Map<String, dynamic>? resultStep = {};
      Map<String, dynamic>? resultDeviceInfo = {};
      errorResult = "";
      // context.loaderOverlay.show();
      FitnessController fitnessController = FitnessController();

      resultDeviceInfo = await fitnessController.getDeviceInfo();
      // debugPrint("resultDeviceInfo: ${resultDeviceInfo['data']}");
      if (resultDeviceInfo['error']) {
        return {
          "error": true,
          "error_message": resultDeviceInfo['error_message']
        };
      }
      resultSleep = await fitnessController.getSleepInfo();
      resultStep = await fitnessController.getStepInfo();
      resultHeart = await fitnessController.getHeartInfo();
      Map<String, dynamic> res = {
        "error": false,
        "error_message": "",
        "resultDeviceInfo": resultDeviceInfo['data'],
        "resultSleep": resultSleep,
        "resultHeart": resultHeart,
        "resultStep": resultStep,
      };
      return res;
    } catch (err) {
      return {
        "error": true,
        "error_message": err
      };
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    Map<String, dynamic>? resultDeviceInfo = {};
    Map<String, dynamic> dataFile = await watch.readLog();
    // debugPrint("dataFile ${dataFile}");
    if (dataFile['error'] == false) {
      contentFile = dataFile["file_content"];

      // DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      twelveAM = DateTime(now.year, now.month, now.day, 0, 0, 0);
      findByDatetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(twelveAM!);
      finfByTimeStamp = twelveAM!.millisecondsSinceEpoch;
      // debugPrint("finfByTimeStamp: ${(finfByTimeStamp/1000).ceil()}");

      findWord = "reportDeviceActive()";  
      // List<String> arrSeri = contentFile.split("\n");
      List<String> arrDevice = ls.convert(contentFile);
      // debugPrint("arrDevice ${arrDevice.length}");
      List<String> deviceElement = [];
      String dataDevice = "";
      for (var element in arrDevice) {
        if (element.contains(findWord)) {
          element = element.replaceAll("，", ", ");
          deviceElement.add(element);
        }
      }
      if (deviceElement.isNotEmpty) {
        dataDevice = deviceElement.last.split("|").last.trim();
        dataDevice = dataDevice.replaceAll("reportDeviceActive()", "").trim();
        int firstIndex = dataDevice.indexOf("(", 0);
        int lastIndex = dataDevice.indexOf(")", 0);
        dataDevice = dataDevice.substring(firstIndex+1, lastIndex);
        // debugPrint("dataDevice: $dataDevice");
        
        Map<String, dynamic> mapDevice = jsonDeviceInfo(dataDevice);
        // debugPrint("mapDevice: $mapDevice");
        resultDeviceInfo = mapDevice;
      }

      return {
        "error": false,
        "error_message": "",
        "data": resultDeviceInfo,
      };
    }
    return {
      "error": true,
      "error_message": dataFile['error_message'],
    };
  }

  Map<String, dynamic> jsonDeviceInfo(deviceInfo) {
    Map<String, dynamic> mapDevice = {};
    String dataString = deviceInfo;
    
    dataString = dataString.replaceAll('notifyConnectStart() called with: ', '');
    dataString = dataString.replaceAll('=', ':');
    // debugPrint("dataString: $dataString");

    // String cleanedString = dataString.replaceAll('{', '').replaceAll('}', '');
    List<String> parts = dataString.split(', ');

    for (var part in parts) {
      // Pisahkan setiap bagian berdasarkan ": "
      List<String> keyValue = part.split(':');
      if (keyValue.length == 2) {
        // Bersihkan nilai (hilangkan tanda kutip untuk nilai string dan tambahkan jika perlu)
        if(keyValue[0].trim() == "did") keyValue[0] = "device_id";
        String value = keyValue[1].replaceAll('"', '').trim();
        mapDevice[keyValue[0].trim()] = value;
      }
    }

    // debugPrint("mapDevice: $mapDevice");
    return mapDevice;
  }

  Future<Map<String, dynamic>> getSleepInfo() async {
    Map<String, dynamic>? resultSleep = {};
    findWord = "mHealthReportAllDaySleepReport";  
      // List<String> arr = contentFile.split("\n");      
      List<String> arr = ls.convert(contentFile);
      List<String> sleepElement = [];
      String dataSleep = "";
      for (var element in arr) {
        if (element.contains(findWord)) {
          if (element.contains((finfByTimeStamp/1000).ceil().toString())) {
            element = element.replaceAll("，", ", ");
            sleepElement.add(element);
          }
        }
      }
      
      dataSleep = sleepElement.last.split("|").last;
      Map<String, dynamic> dailySleepReport = jsonDailySleepReport(dataSleep);
      // debugPrint("dailySleepReport: $dailySleepReport");
      resultSleep = dailySleepReport;
      return resultSleep;
  }

  Map<String, dynamic> jsonDailyStepReport(data) {
    // Buat map kosong untuk menyimpan pasangan key-value
    Map<String, dynamic> dailyStepReport = {};
    String dataString = data;
    dataString = dataString.substring(1, dataString.length - 1);
    
    dataString = dataString.replaceAll('DailyStepReport', '');
    dataString = dataString.replaceAll('(', '{');
    dataString = dataString.replaceAll(')', '}');
    dataString = dataString.replaceAll('=', ': ');
    // debugPrint("dataString $dataString");
    String cleanedString = dataString.replaceAll('{', '').replaceAll('}', '');
    // debugPrint("cleanedString $cleanedString");

    // Pisahkan bagian-bagian berdasarkan koma
    List<String> parts = cleanedString.split(', ');

    // Iterasi setiap bagian dan tambahkan ke map jsonData
    for (var part in parts) {
      // Pisahkan setiap bagian berdasarkan ": "
      List<String> keyValue = part.split(': ');
      // Bersihkan nilai (hilangkan tanda kutip untuk nilai string dan tambahkan jika perlu)
      String value = keyValue[1].replaceAll('"', '');
      if (keyValue[0].contains('time ')) {
        value = '"${value.trim()}"';
        keyValue[0] = 'datetime';
      }

      // Tambahkan ke map jsonData
      if (keyValue[0].trim() == 'stepRecords') {
        
      } else {
        dailyStepReport[keyValue[0]] = value;
      }
    }
    return dailyStepReport;
  }

  Future<Map<String, dynamic>> getStepInfo() async {
    Map<String, dynamic>? resultStep = {};
    findWord = "DailyStepReport";
      List<String> arrStep = contentFile.split("\n");
      List<String> stepElement = [];
      String dataStep = "";
      for (var element in arrStep) {
        // debugPrint("element: ${element}");
        if (element.contains(findWord)) {
          if (element.contains(findByDatetime)) {
            stepElement.add(element);
          }
        }
      }
      dataStep = stepElement.last.split(" - ")[1];
      Map<String, dynamic> dailyStepReport = jsonDailyStepReport(dataStep);
      resultStep = dailyStepReport;
      return resultStep;
  }

  Map<String, dynamic> jsonDailySleepReport(data) {
    Map<String, dynamic> dailySleepReport = {};
    String dataString = data;
    
    dataString = dataString.replaceAll('dataModel.mHealthReportAllDaySleepReport', '');
    dataString = dataString.replaceAll('=', ':');

    String cleanedString = dataString.replaceAll('{', '').replaceAll('}', '');
    List<String> parts = cleanedString.split(', ');

    for (var part in parts) {
      // Pisahkan setiap bagian berdasarkan ": "
      List<String> keyValue = part.split(':');
      if (keyValue.length == 2) {
        // Bersihkan nilai (hilangkan tanda kutip untuk nilai string dan tambahkan jika perlu)
        String value = keyValue[1].replaceAll('"', '').trim();
        dailySleepReport[keyValue[0]] = value;
      }
    }
    String totalDuration = Tools().intToTimeLeft(int.parse(dailySleepReport["totalDuration"]));
    String deepDuration = Tools().intToTimeLeft(int.parse(dailySleepReport["deepDuration"]));
    String lightDuration = Tools().intToTimeLeft(int.parse(dailySleepReport["lightDuration"]));
    dailySleepReport["totalDurationTime"] = totalDuration;
    dailySleepReport["totalDeepSleepTime"] = deepDuration;
    dailySleepReport["totalLightDurationTime"] = lightDuration;

    // debugPrint("dailySleepReport: $dailySleepReport");
    return dailySleepReport;
  }

  Future<Map<String, dynamic>> getHeartInfo() async {
    Map<String, dynamic>? resultHeart = {};
    findWord = "[HomeDataRepository] HR";      
    // List<String> arrHeart = contentFile.split("\n");
    List<String> arrHeart = ls.convert(contentFile);
    List<String> heartElement = [];
    String dataheart = "";

    for (var element in arrHeart) {
      // debugPrint("element: $element");
      if (element.contains(findWord)) {
        if (element.contains((finfByTimeStamp/1000).ceil().toString())) {
          // debugPrint("element $element");
          element = element.replaceAll("，", ", ");
          heartElement.add(element);
        }
      }
    }
      
    // debugPrint("heartElement: ${heartElement.length}");
    // debugPrint("heartElement last: ${heartElement.last}");
    dataheart = heartElement.last.split("|").last.trim();
    // debugPrint("dataheart: $dataheart");
    Map<String, dynamic> dailyHeartReport = jsonDailyHeartReport(dataheart);
    resultHeart = dailyHeartReport;
    return resultHeart;
  }
  
  Map<String, dynamic> jsonDailyHeartReport(data) {
    Map<String, dynamic> dailyHeartReport = {};
    String dataString = data;
    dataString = dataString.replaceAll('[HomeDataRepository] HR - ', '');
    dataString = dataString.substring(1, dataString.length - 1);
    dataString = dataString.replaceAll('DailyHrReport', '');
    // debugPrint("dataString: $dataString");

    String cleanedString = dataString.substring(1, dataString.length - 1);
    List<String> parts = cleanedString.split(', ');
    for (var part in parts) {
      List<String> keyValue = part.split('=');
      if (keyValue.length == 2) {
        // debugPrint("keyValue: ${keyValue[0]} >> ${keyValue[1]}");
        String value = keyValue[1].replaceAll('"', '').trim();
        if (keyValue[0].contains('time ')) {
          keyValue[0] = 'datetime';
        }
        dailyHeartReport[keyValue[0]] = value.replaceAll(")", "");
      }      
    }
    
    return dailyHeartReport;
  }
}