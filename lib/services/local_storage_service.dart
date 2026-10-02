import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  const LocalStorageService();

  Future<Directory> get _root async {
    final documents = await getApplicationDocumentsDirectory();
    final root = Directory('${documents.path}/worklog');
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  Future<File> get _stateFile async {
    final root = await _root;
    return File('${root.path}/state.json');
  }

  Future<Map<String, dynamic>?> readState() async {
    try {
      final file = await _stateFile;
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeState(Map<String, dynamic> state) async {
    final file = await _stateFile;
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(state), flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await temporary.rename(file.path);
  }

  Future<String> persistPickedImage({
    required XFile source,
    required String jobId,
    required String category,
  }) async {
    final root = await _root;
    final directory = Directory('${root.path}/media/$jobId/$category');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final extension = _extensionOf(source.path);
    final target = File(
      '${directory.path}/${DateTime.now().microsecondsSinceEpoch}.$extension',
    );
    await File(source.path).copy(target.path);
    return target.path;
  }

  Future<String> persistBytes({
    required Uint8List bytes,
    required String directoryName,
    required String fileName,
  }) async {
    final root = await _root;
    final directory = Directory('${root.path}/$directoryName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return 'jpg';
    final extension = path.substring(dot + 1).toLowerCase();
    if (extension.length > 5) return 'jpg';
    return extension;
  }
}
