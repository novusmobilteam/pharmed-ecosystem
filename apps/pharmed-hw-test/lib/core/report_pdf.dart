// Markasız PDF test raporu (A4). Logo ve ürün adı yoktur.
//
// Font: uygulamaya paketli DM Sans / JetBrains Mono (Türkçe karakterler
// dahil). Sahadaki bilgisayarda internet gerekmez (PdfGoogleFonts kullanılmaz).
// Renkler pharmed_ui MedColors token değerleridir.

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'cabin_model.dart';
import 'report.dart';
import 'test_status.dart';
import 'traffic_log.dart';

// MedColors karşılıkları.
const _green = PdfColor.fromInt(0xFF0D9E6C);
const _red = PdfColor.fromInt(0xFFDC2626);
const _amber = PdfColor.fromInt(0xFFD97006);
const _blue = PdfColor.fromInt(0xFF1A6FD8);
const _text = PdfColor.fromInt(0xFF1A2332);
const _text2 = PdfColor.fromInt(0xFF3D4F66);
const _text3 = PdfColor.fromInt(0xFF7A8FA8);
const _border = PdfColor.fromInt(0xFFDDE3EC);
const _surface = PdfColor.fromInt(0xFFF4F6FA);

PdfColor _statusColor(TestStatus s) => switch (s) {
  TestStatus.passed => _green,
  TestStatus.failed => _red,
  TestStatus.warning => _amber,
  TestStatus.running => _blue,
  TestStatus.pending || TestStatus.skipped || TestStatus.info => _text3,
};

String _statusText(TestStatus s) => s.isFinished ? s.label : 'Yapılmadı';

String _two(int v) => v.toString().padLeft(2, '0');

String _dateTime(DateTime t) => '${_two(t.day)}.${_two(t.month)}.${t.year} ${_two(t.hour)}:${_two(t.minute)}';

/// Kart cevaplarındaki kontrol karakterleri ve fontta olmayan işaretler PDF'e
/// yazılmadan önce temizlenir.
String _clean(String s) => s.replaceAll(RegExp(r'[^\n\x20-\x7E\u00A0-\u024F\u2013-\u2026\u2192]'), '?');

Future<pw.Font> _font(String asset) async => pw.Font.ttf(await rootBundle.load(asset));

Future<Uint8List> buildReportPdf({
  required ReportInfo info,
  required CabinSnapshot? cabin,
  required List<String> serumLines,
  required List<ReportScenario> scenarios,
  required List<FailedStep> failed,
  required int stepCount,
}) async {
  final regular = await _font('assets/fonts/DMSans-Regular.ttf');
  final bold = await _font('assets/fonts/DMSans-SemiBold.ttf');
  final mono = await _font('assets/fonts/JetBrainsMono-Regular.ttf');

  const small = pw.TextStyle(fontSize: 8, color: _text2);
  final h2 = pw.TextStyle(fontSize: 11, font: bold, color: _text);
  final monoStyle = pw.TextStyle(fontSize: 6.5, font: mono, color: _text2);

  int count(TestStatus s) => scenarios.where((x) => x.status == s).length;
  final waiting = scenarios.where((x) => !x.status.isFinished).length;

  pw.Widget section(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
    child: pw.Text(title, style: h2),
  );

  pw.Widget infoRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 90, child: pw.Text(label, style: const pw.TextStyle(fontSize: 8.5, color: _text3))),
        pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 8.5, color: _text))),
      ],
    ),
  );

  pw.Widget countBox(String label, int value, PdfColor color) => pw.Expanded(
    child: pw.Container(
      margin: const pw.EdgeInsets.only(right: 6),
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$value', style: pw.TextStyle(fontSize: 14, font: bold, color: color)),
          pw.Text(label, style: small),
        ],
      ),
    ),
  );

  pw.Widget headerRow(List<String> cells, List<int> flexes) => pw.Container(
    color: _surface,
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      children: [
        for (var i = 0; i < cells.length; i++)
          pw.Expanded(
            flex: flexes[i],
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 3),
              child: pw.Text(cells[i], style: pw.TextStyle(fontSize: 7.5, font: bold, color: _text2)),
            ),
          ),
      ],
    ),
  );

  pw.Widget row(List<pw.Widget> cells, List<int> flexes) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _border, width: 0.5))),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cells.length; i++)
          pw.Expanded(
            flex: flexes[i],
            child: pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 3), child: cells[i]),
          ),
      ],
    ),
  );

  pw.Widget t(String s, {PdfColor color = _text, pw.Font? font}) =>
      pw.Text(_clean(s), style: pw.TextStyle(fontSize: 8, color: color, font: font));

  // ── Senaryolar, kabin bazında ──
  final groups = <String, List<ReportScenario>>{};
  for (final s in scenarios) {
    groups.putIfAbsent(s.group, () => []).add(s);
  }
  const scenarioFlex = [12, 38, 22, 28];

  final doc = pw.Document(title: 'Donanım Test Raporu', author: info.user ?? '');
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 28),
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Donanım Test Raporu · ${_dateTime(info.time)}', style: const pw.TextStyle(fontSize: 7, color: _text3)),
          pw.Text('Sayfa ${context.pageNumber} / ${context.pagesCount}', style: const pw.TextStyle(fontSize: 7, color: _text3)),
        ],
      ),
      build: (context) => [
        pw.Text('Donanım Test Raporu', style: pw.TextStyle(fontSize: 18, font: bold, color: _text)),
        pw.SizedBox(height: 10),
        infoRow('Tarih', _dateTime(info.time)),
        infoRow('Teknisyen', info.user ?? '-'),
        infoRow('Kabin tipi', info.cabinType ?? '-'),
        if (cabin != null) infoRow('Kabin tanımı', '${cabin.source.label} · ${cabin.summary}'),
        infoRow('Bilgisayar', info.host),
        infoRow('COM port', info.port ?? '-'),
        infoRow('Uygulama', info.appVersion),

        // ── Özet ──
        section('Özet'),
        pw.Row(
          children: [
            countBox('Başarılı', count(TestStatus.passed), _green),
            countBox('Başarısız', count(TestStatus.failed), _red),
            countBox('Atlandı', count(TestStatus.skipped), _text3),
            countBox('Yapılmadı', waiting, _text3),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text('${scenarios.length} test senaryosu · $stepCount kayıtlı adım', style: small),

        // ── Kabin ──
        if (cabin != null && cabin.cabins.isNotEmpty) ...[
          section('Kabin'),
          for (final c in cabin.cabins) ...[
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
              child: pw.Text(
                '${c.title}${c.name != null ? '  (${c.name})' : ''}',
                style: pw.TextStyle(fontSize: 9, font: bold, color: _text),
              ),
            ),
            if (c.needsLidCount) t('Kapak sayısı karttan okunamaz; testte tanımlandı.', color: _amber),
            for (final w in c.warnings) t('Uyarı: $w', color: _amber),
            for (final u in c.units)
              row([
                t(u.locationLabel, font: mono),
                t(u.name),
                t(u.compartmentCount != null && u.kind != UnitKind.serum ? '${u.compartmentCount} göz' : ''),
                t(u.problem ?? '', color: _red),
              ], const [22, 38, 12, 28]),
          ],
        ],

        // ── Senaryolar ──
        if (scenarios.isNotEmpty) ...[
          section('Test senaryoları'),
          for (final entry in groups.entries) ...[
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 6, bottom: 2),
              child: pw.Text(entry.key, style: pw.TextStyle(fontSize: 9, font: bold, color: _text)),
            ),
            headerRow(const ['Durum', 'Test', 'Konum', 'Sonuç'], scenarioFlex),
            for (final s in entry.value)
              row([
                pw.Text(
                  _statusText(s.status),
                  style: pw.TextStyle(fontSize: 8, font: bold, color: _statusColor(s.status)),
                ),
                t(s.title),
                t(s.location, color: _text2, font: mono),
                t(s.detail ?? '', color: _text2),
              ], scenarioFlex),
          ],
        ],

        // ── Serum tanımı ──
        if (serumLines.isNotEmpty) ...[
          section('Serum tanımı (testte kullanılan, kaydedilmedi)'),
          for (final line in serumLines)
            pw.Padding(
              padding: pw.EdgeInsets.only(left: (line.length - line.trimLeft().length) * 3.0, bottom: 1),
              child: t(line.trimLeft(), color: _text2),
            ),
        ],

        // ── Hatalı adımlar ──
        section('Hatalı adımlar (${failed.length})'),
        if (failed.isEmpty)
          t('Hatalı adım yok.', color: _text2)
        else
          for (final f in failed)
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _border, width: 0.6),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(width: 60, child: t(formatTime(f.step.time).substring(0, 8), color: _text3, font: mono)),
                      pw.Expanded(
                        child: pw.Text(_clean(f.step.title), style: pw.TextStyle(fontSize: 8.5, font: bold, color: _red)),
                      ),
                    ],
                  ),
                  if (f.step.detail != null && f.step.detail!.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 60, top: 2),
                      child: t(f.step.detail!, color: _text2),
                    ),
                  if (f.traffic.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 60, top: 4),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Ham trafik (${f.traffic.length}${f.totalTraffic > f.traffic.length ? ' / ${f.totalTraffic}' : ''})',
                            style: const pw.TextStyle(fontSize: 7, color: _text3),
                          ),
                          for (final e in f.traffic) pw.Text(_clean(e.toLine()), style: monoStyle),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        pw.Text(
          'Tüm adımlar ve hat trafiğinin tamamı aynı adlı .txt raporda yer alır.',
          style: const pw.TextStyle(fontSize: 7.5, color: _text3),
        ),

        // ── İmza ──
        pw.SizedBox(height: 24),
        pw.Row(
          children: [
            pw.Expanded(child: _signature('Teknisyen', info.user ?? '')),
            pw.SizedBox(width: 24),
            pw.Expanded(child: _signature('Teslim alan', '')),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

pw.Widget _signature(String label, String name) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _text3)),
    pw.SizedBox(height: 4),
    pw.Text(name.isEmpty ? ' ' : name, style: const pw.TextStyle(fontSize: 9, color: _text)),
    pw.SizedBox(height: 22),
    pw.Container(height: 0.6, color: _text3),
    pw.SizedBox(height: 2),
    pw.Text('İmza', style: const pw.TextStyle(fontSize: 7, color: _text3)),
  ],
);
