import 'dart:io';

import 'package:image/image.dart' as img;

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Navedi barem jedan direktorij sa PNG screenshotovima.');
    exitCode = 64;
    return;
  }

  for (final directoryPath in args) {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      stderr.writeln('Direktorij ne postoji: $directoryPath');
      exitCode = 2;
      return;
    }

    final files =
        directory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('.png'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    if (files.isEmpty) {
      stderr.writeln('Nema PNG datoteka u: $directoryPath');
      exitCode = 3;
      return;
    }

    for (final file in files) {
      final decoded = img.decodePng(await file.readAsBytes());
      if (decoded == null) {
        stderr.writeln('PNG se ne može dekodirati: ${file.path}');
        exitCode = 4;
        return;
      }

      final rgb = decoded.convert(numChannels: 3);
      final encoded = img.encodePng(rgb, level: 6);
      await file.writeAsBytes(encoded, flush: true);
      stdout.writeln(
        '${file.path}: ${rgb.width}x${rgb.height} RGB bez alpha kanala',
      );
    }
  }
}
