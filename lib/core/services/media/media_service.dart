import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromCamera() async {
    // Check current status first — avoids double-prompting
    var status = await Permission.camera.status;

    if (status.isPermanentlyDenied) {
      // User denied and checked "Don't ask again" — send to settings
      await openAppSettings();
      return null;
    }

    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) return null;
    }

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked == null) return null;
      return File(picked.path);
    } catch (e) {
      debugPrint("[MediaService] Camera error: $e");
      return null;
    }
  }

  Future<File?> pickFromGallery() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ uses READ_MEDIA_IMAGES
        status = await Permission.photos.status;
        if (status.isPermanentlyDenied) {
          await openAppSettings();
          return null;
        }
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }
      } else {
        // Android 12 and below uses READ_EXTERNAL_STORAGE
        status = await Permission.storage.status;
        if (status.isPermanentlyDenied) {
          await openAppSettings();
          return null;
        }
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }
    } else {
      status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }
    }

    if (!status.isGranted) return null;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked == null) return null;
      return File(picked.path);
    } catch (e) {
      debugPrint("[MediaService] Gallery error: $e");
      return null;
    }
  }
}