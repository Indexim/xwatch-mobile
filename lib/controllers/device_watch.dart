import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DevicesWatch {
  readFilesFromCustomDevicePath() async {
    // Retrieve "External Storage Directory" for Android and "NSApplicationSupportDirectory" for iOS
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();

    // Create a new file. You can create any kind of file like txt, doc , json etc.
    File file = await File("${directory?.path}/Toastguyz.json").create();

    // Read the file content
    String fileContent = await file.readAsString();
    debugPrint("fileContent : $fileContent");
  }

  Future<String> get _directoryPath async { 
    Directory? directory = await getApplicationDocumentsDirectory(); 
    return directory.path; 
  }

  Future<String> getPath() async {
    Directory? directory = (Platform.isAndroid
        ? await ExternalPath.getExternalStorageDirectories()
        : await getApplicationSupportDirectory()) as Directory?;
    return directory!.path; 
  } 

  Future<File> getFile(String fileNameWithExtension) async { 
    final path = await _directoryPath;
    debugPrint("path $path");
    return File("$path/$fileNameWithExtension"); 
  }

  readTextFile(String fileNameWithExtension) async {
    final file = await getFile(fileNameWithExtension); 
    final fileContent = await file.readAsString(); 
    return fileContent; 
  }

  getPathExternal() async {
    var paths = await ExternalPath.getExternalStorageDirectories();
    debugPrint("external $paths}");

    Directory yyy = Directory("${paths[0]}/Android/data/com.xiaomi.wearable/files/");
    debugPrint("xxx $paths");
    final List<FileSystemEntity> files = yyy.listSync();
    debugPrint("files $files");
    return paths;
  }

  readLog() async {
    try {
      final permissionStatus = await Permission.storage.status;
      if (permissionStatus.isDenied) {
          // Here just ask for the permission for the first time
          await Permission.storage.request();

          // I noticed that sometimes popup won't show after user press deny
          // so I do the check once again but now go straight to appSettings
          if (permissionStatus.isDenied) {
              await openAppSettings();
          }
      } else if (permissionStatus.isPermanentlyDenied) {
          // Here open app settings for user to manually enable permission in case 
          // where permission was permanently denied
          await openAppSettings();
      } else {
          // Do stuff that require permission here
          // debugPrint("permissionStatus $permissionStatus");
      }

      // Directory? directory;
      // directory = await getExternalStorageDirectory();
      // debugPrint("directory: ${directory!.path}");
      // // String logFilePath = "${directory!.path}/logs/test.log";
      // directory = await getApplicationDocumentsDirectory();
      // debugPrint("getApplicationDocumentsDirectory: ${directory.parent.parent.path }");

      var paths = await ExternalPath.getExternalStorageDirectories();
      // debugPrint("=========> paths: $paths");
      String logFilePath = '${paths[0]}/Android/data/com.xiaomi.wearable/files/log/XiaomiFit.main.log';
      // debugPrint("logFilePath $logFilePath");
      // Check if the file exists
      if (!await File(logFilePath).exists()) {
        throw const FileSystemException('File not found');
      } else {
        // debugPrint("File found $logFilePath");
      }

      final file = File(logFilePath); 
      final fileContent = await file.readAsString();
      // debugPrint("contentFIle: ${fileContent}");
      return {
        "error": false,
        "error_message": "",
        "file_content": fileContent
      };
    } catch (error) {
      // debugPrint("You found error on $error");
      return {
        "error": true,
        "error_message": "Error $error",
        "file_content": ""
      };
    }
  }

  copyLogToLocal() async {
    try {
      final permissionStatus = await Permission.storage.status;
      if (permissionStatus.isDenied) {
          // Here just ask for the permission for the first time
          await Permission.storage.request();

          // I noticed that sometimes popup won't show after user press deny
          // so I do the check once again but now go straight to appSettings
          if (permissionStatus.isDenied) {
              await openAppSettings();
          }
      } else if (permissionStatus.isPermanentlyDenied) {
          // Here open app settings for user to manually enable permission in case 
          // where permission was permanently denied
          await openAppSettings();
      } else {
          // Do stuff that require permission here
          // debugPrint("permissionStatus $permissionStatus");
      }

      Directory? directory;
      var paths = await ExternalPath.getExternalStorageDirectories();
      String logFilePath = '${paths[0]}/Android/data/com.xiaomi.wearable/files/log/XiaomiFit.main.log';
      
      // debugPrint("logFilePath $logFilePath");
      // Check if the file exists
      if (!await File(logFilePath).exists()) {
        throw const FileSystemException('File not found');
      } else {
        debugPrint("File found $logFilePath");
      }

      directory = await getExternalStorageDirectory();
      debugPrint("directory ${directory!.path}");

      final Directory newDirectory = Directory('${directory.path}/logs');
      if (!await newDirectory.exists()) {
        await newDirectory.create(recursive: true); // Create recursively
      }

      // Copy the log file to the internal storage
      final File logFile = File(logFilePath);
      File copy = await logFile.copy('${newDirectory.path}/XiaomiFit.main.log');
      
      debugPrint("Log file copied to: ${copy.path}");
    } catch (error) {
      debugPrint("Error copying log file: $error");
    }
  }
}