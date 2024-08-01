import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xwatch/shared/utils.dart';

class DashboardController {
  // static const baseUrl = 'http://xwatch.idcapps.net';
  // static const baseUrl = 'http://172.16.1.95:2109';
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 4),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      receiveDataWhenStatusError: true,

      baseUrl: Utils.baseUrl, // Ganti dengan IP server dan port Anda
      headers: {
        // "Content-Type": "application/json", // application/json
        'Accept': 'application/json',
        'Connection': 'Keep-Alive',
      },
    ),
  );

  Future<Map<String, dynamic>> sinkronData(data, Map<String, dynamic>? resultDeviceInfo, auth) async {
    Response response;    
    try {
      // debugPrint("data: $data");
      // debugPrint("resultDeviceInfo: $resultDeviceInfo");
      if (auth!['serialNo'] == data['seri_no']) {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getString("lastLog") == DateFormat("yyyyMMdd").format(DateTime.now())) {
          response = await dio.post('/api/fitness/update', data: json.encode(data));
          return {"error": "", "data": response.data};
        } else {
          response = await dio.post('/api/fitness/insert', data: json.encode(data));
          prefs.setString("lastLog", DateFormat("yyyyMMdd").format(DateTime.now()));
          return {"error": "", "data": response.data};
        }
      } else {
        return {"error": "Nomor seri perangkat dan user tidak sama", "data": {}};
      }
    } on DioException catch (err) {
      
      debugPrint("error cak $err");
      return {"error": err};
    }
  }
}