import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';
import 'local_storage_service.dart';

class DeviceMediaService {
  DeviceMediaService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pickJobPhoto({
    required LocalStorageService storage,
    required WorkJob job,
    required bool before,
    required ImageSource source,
  }) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 86,
      maxWidth: 2200,
    );
    if (image == null) return null;

    return storage.persistPickedImage(
      source: image,
      jobId: job.id,
      category: before ? 'prije' : 'poslije',
    );
  }

  Future<List<String>> recoverLostImages({
    required LocalStorageService storage,
    required WorkJob job,
  }) async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty || response.files == null) return const [];

    final recovered = <String>[];
    for (final file in response.files!) {
      if (!await File(file.path).exists()) continue;
      recovered.add(
        await storage.persistPickedImage(
          source: file,
          jobId: job.id,
          category: 'oporavljeno',
        ),
      );
    }
    return recovered;
  }
}

class ExternalActionService {
  const ExternalActionService();

  Future<bool> call(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return launchUrl(Uri(scheme: 'tel', path: cleaned));
  }

  Future<bool> openNavigation(String address) {
    final query = Uri.encodeComponent(address);
    return launchUrl(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<bool> email(String address, {String? subject}) {
    return launchUrl(
      Uri(
        scheme: 'mailto',
        path: address,
        queryParameters: {
          if (subject != null && subject.isNotEmpty) 'subject': subject,
        },
      ),
    );
  }

  static Rect shareOrigin(BuildContext context) {
    final object = context.findRenderObject();
    if (object is RenderBox && object.hasSize) {
      return object.localToGlobal(Offset.zero) & object.size;
    }
    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 1,
      height: 1,
    );
  }
}
