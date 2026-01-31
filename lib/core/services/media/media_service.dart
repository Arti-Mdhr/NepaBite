import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      return null;
    }

    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;

    return File(picked.path);
  }

   Future<File?> pickFromGallery() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return null;
    }

    if (!status.isGranted) {
      return null;
    }

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    return File(picked.path);
  }
}
