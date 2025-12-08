import 'dart:io';

import 'package:iam/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';

class PickAvatarService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickAvatar(
    ImageSource source, {
    BuildContext? context,
  }) async {
    try {
      debugPrint(
        'pickAvatar: Starting, source: ${source == ImageSource.camera ? "camera" : "gallery"}',
      );

      if (source == ImageSource.camera) {
        // Request camera permission (needed for both iOS and Android)
        debugPrint('pickAvatar: Requesting camera permission');
        final cameraStatus = await Permission.camera.request();
        debugPrint(
          'pickAvatar: Camera permission status: ${cameraStatus.isGranted}',
        );
        if (!cameraStatus.isGranted) {
          debugPrint('pickAvatar: Camera permission denied');
          return null;
        }
      } else {
        // For gallery, only request permission on Android
        // On iOS, image_picker handles permission requests automatically
        if (Platform.isAndroid) {
          debugPrint('pickAvatar: Requesting photos permission (Android)');
          final photosStatus = await Permission.photos.request();
          if (!photosStatus.isGranted) {
            final storageStatus = await Permission.storage.request();
            if (!storageStatus.isGranted) {
              debugPrint(
                'pickAvatar: Photos/storage permission denied (Android)',
              );
              return null;
            }
          }
        } else {
          // iOS: image_picker will handle permission request automatically
          debugPrint(
            'pickAvatar: Skipping permission request on iOS (image_picker handles it)',
          );
        }
      }

      // Use ImagePicker with proper error handling
      debugPrint('pickAvatar: Calling ImagePicker.pickImage');
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        requestFullMetadata: false,
      );

      debugPrint('pickAvatar: ImagePicker returned: ${file != null}');
      if (file != null) {
        debugPrint('pickAvatar: File path: ${file.path}');
      }

      if (file == null) return null;

      debugPrint('pickAvatar: Starting image cropper');
      final cropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressQuality: 95,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            statusBarColor: AppColors.primaryColor,
            backgroundColor: Colors.black,
            hideBottomControls: false,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      debugPrint('pickAvatar: Image cropper returned: ${cropped != null}');
      if (cropped == null) return null;

      debugPrint('pickAvatar: Returning cropped file: ${cropped.path}');
      return File(cropped.path);
    } catch (e, stackTrace) {
      debugPrint('Error picking avatar: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<File?> pickImageWithoutCrop(
    ImageSource source, {
    BuildContext? context,
  }) async {
    try {
      debugPrint(
        'pickImageWithoutCrop: Starting, source: ${source == ImageSource.camera ? "camera" : "gallery"}',
      );

      if (source == ImageSource.camera) {
        // Request camera permission (needed for both iOS and Android)
        debugPrint('pickImageWithoutCrop: Requesting camera permission');
        final cameraStatus = await Permission.camera.request();
        debugPrint(
          'pickImageWithoutCrop: Camera permission status: ${cameraStatus.isGranted}',
        );
        if (!cameraStatus.isGranted) {
          debugPrint('pickImageWithoutCrop: Camera permission denied');
          return null;
        }
      } else {
        // For gallery, only request permission on Android
        // On iOS, image_picker handles permission requests automatically
        if (Platform.isAndroid) {
          debugPrint(
            'pickImageWithoutCrop: Requesting photos permission (Android)',
          );
          final photosStatus = await Permission.photos.request();
          if (!photosStatus.isGranted) {
            final storageStatus = await Permission.storage.request();
            if (!storageStatus.isGranted) {
              debugPrint(
                'pickImageWithoutCrop: Photos/storage permission denied (Android)',
              );
              return null;
            }
          }
        } else {
          // iOS: image_picker will handle permission request automatically
          debugPrint(
            'pickImageWithoutCrop: Skipping permission request on iOS (image_picker handles it)',
          );
        }
      }

      // Use ImagePicker with proper error handling
      debugPrint('pickImageWithoutCrop: Calling ImagePicker.pickImage');
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        requestFullMetadata: false,
      );

      debugPrint('pickImageWithoutCrop: ImagePicker returned: ${file != null}');
      if (file != null) {
        debugPrint('pickImageWithoutCrop: File path: ${file.path}');
      }

      if (file == null) return null;

      return File(file.path);
    } catch (e, stackTrace) {
      debugPrint('Error picking image: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}
