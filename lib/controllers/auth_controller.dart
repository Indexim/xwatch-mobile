// import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xwatch/shared/utils.dart';

class AuthController{
  // static const baseUrl = 'http://172.16.1.95:2109';
  // static const baseUrl = 'http://xwatch.idcapps.net';
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
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

  Future<Map<String, dynamic>> login(data) async {
    Response response;    
    try {
      response = await dio.post('/api/auth/login', data: data);
      return response.data;
    } on DioException catch (err) {
      
      debugPrint("error cak $err");
      return {"status": "failed", "error": err};
    }
  }
}