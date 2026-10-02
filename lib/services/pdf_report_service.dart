import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models.dart';
import 'device_services.dart';
import 'local_storage_service.dart';

class PdfReportService {
  const PdfReportService(this.storage);

  final LocalStorageService storage;

  Future<File> generate(WorkJob job) async {
    final document = pw.Document(
      title: 'WORKLOG - ${_pdfSafe(job.title)}',
      author: 'WORKLOG',
      subject: 'Zapisnik izvedenih radova',
    );

    final beforeImages = await _readImages(job.beforePhotoPaths);
    final afterImages = await _readImages(job.afterPhotoPaths);
    final signatureBytes = await _readOptional(job.signaturePath);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(34),
        header: (context) => _header(),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'WORKLOG • Stranica ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 12),
          pw.Text(
            _pdfSafe(job.title),
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Zapisnik izvedenih radova',
            style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 18),
          _section(
            'Podaci o poslu',
            [
              _row('Klijent', job.client.name),
              _row('Telefon', job.client.phone),
              _row('Lokacija', job.location),
              _row('Datum', job.dateLabel),
              _row('Vrijeme', job.timeLabel),
              _row('Status', job.statusLabel),
              _row('Prioritet', job.priority),
              _row(
                'Terenski tehnicar',
                job.assignedMemberName ?? 'Nije dodijeljeno',
              ),
            ],
          ),
          if (job.description.trim().isNotEmpty)
            _section(
              'Opis posla',
              [
                pw.Text(_pdfSafe(job.description)),
              ],
            ),
          _section(
            'Evidencija rada',
            [
              _row('Ukupno evidentirano', _duration(job.minutesWorked)),
            ],
          ),
          _section(
            'Materijal',
            job.materials.isEmpty
                ? [pw.Text('Nema evidentiranog materijala.')]
                : [
                    pw.TableHelper.fromTextArray(
                      headers: const ['Stavka', 'Kolicina', 'Vrijednost'],
                      data: job.materials
                          .map(
                            (item) => [
                              _pdfSafe(item.name),
                              _pdfSafe(item.quantity),
                              '${item.price.toStringAsFixed(2)} EUR',
                            ],
                          )
                          .toList(),
                      headerDecoration: const pw.BoxDecoration(
                        color: PdfColors.blue800,
                      ),
                      headerStyle: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                      ),
                      cellStyle: const pw.TextStyle(fontSize: 9),
                      cellPadding: const pw.EdgeInsets.all(6),
                    ),
                  ],
          ),
          if (job.notes.isNotEmpty)
            _section(
              'Biljeske',
              job.notes
                  .map(
                    (note) => pw.Bullet(
                      text: _pdfSafe(note),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  )
                  .toList(),
            ),
          if (beforeImages.isNotEmpty || afterImages.isNotEmpty)
            _photoSection(beforeImages, afterImages),
          if (signatureBytes != null)
            _section(
              'Potpis klijenta',
              [
                pw.Container(
                  height: 100,
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Image(
                    pw.MemoryImage(signatureBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  _pdfSafe(job.client.name),
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              border: pw.Border.all(color: PdfColors.green500),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(7)),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  'POSAO DOVRSEN',
                  style: pw.TextStyle(
                    color: PdfColors.green800,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  'Generirano u WORKLOG aplikaciji',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final bytes = await document.save();
    final name = _safeFileName(job.title);
    final path = await storage.persistBytes(
      bytes: bytes,
      directoryName: 'izvjestaji',
      fileName: '$name-${job.id}.pdf',
    );
    job.reportPath = path;
    return File(path);
  }

  Future<ShareResult> share(
    BuildContext context,
    File file,
    WorkJob job,
  ) {
    return SharePlus.instance.share(
      ShareParams(
        title: 'WORKLOG zapisnik',
        subject: 'WORKLOG zapisnik - ${job.title}',
        text: 'Zapisnik izvedenih radova: ${job.title} • ${job.client.name}',
        files: [XFile(file.path)],
        sharePositionOrigin: ExternalActionService.shareOrigin(context),
      ),
    );
  }

  pw.Widget _header() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue800, width: 1.4),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 26,
            height: 26,
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue800,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'W',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: 'WORK',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                pw.TextSpan(
                  text: 'LOG',
                  style: pw.TextStyle(
                    color: PdfColors.blue800,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          pw.Spacer(),
          pw.Text(
            'Dokaz obavljenog posla, bez kaosa.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  pw.Widget _section(String title, List<pw.Widget> children) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(7)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _pdfSafe(title),
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              _pdfSafe(label),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              _pdfSafe(value),
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _photoSection(
    List<Uint8List> before,
    List<Uint8List> after,
  ) {
    return _section(
      'Fotografije prije i poslije',
      [
        if (before.isNotEmpty) ...[
          pw.Text(
            'Prije',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          _photoGrid(before),
          pw.SizedBox(height: 10),
        ],
        if (after.isNotEmpty) ...[
          pw.Text(
            'Poslije',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          _photoGrid(after),
        ],
      ],
    );
  }

  pw.Widget _photoGrid(List<Uint8List> images) {
    final selected = images.take(6).toList();
    return pw.Wrap(
      spacing: 6,
      runSpacing: 6,
      children: selected
          .map(
            (bytes) => pw.Container(
              width: 150,
              height: 105,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Image(
                pw.MemoryImage(bytes),
                fit: pw.BoxFit.cover,
              ),
            ),
          )
          .toList(),
    );
  }

  Future<List<Uint8List>> _readImages(List<String> paths) async {
    final result = <Uint8List>[];
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          result.add(await file.readAsBytes());
        }
      } catch (_) {
        // Neispravna ili nepodrzana slika ne smije prekinuti cijeli zapisnik.
      }
    }
    return result;
  }

  Future<Uint8List?> _readOptional(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  String _duration(int minutes) {
    final safe = mathMax(minutes, 0);
    final hours = safe ~/ 60;
    final rest = safe % 60;
    return '$hours h $rest min';
  }

  int mathMax(int a, int b) => a > b ? a : b;

  String _safeFileName(String input) {
    final value = _pdfSafe(input)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return value.isEmpty ? 'worklog-zapisnik' : value;
  }

  String _pdfSafe(String value) {
    const replacements = {
      'č': 'c',
      'ć': 'c',
      'đ': 'd',
      'š': 's',
      'ž': 'z',
      'Č': 'C',
      'Ć': 'C',
      'Đ': 'D',
      'Š': 'S',
      'Ž': 'Z',
      '–': '-',
      '—': '-',
      '•': '-',
    };
    var output = value;
    for (final entry in replacements.entries) {
      output = output.replaceAll(entry.key, entry.value);
    }
    return output;
  }
}
