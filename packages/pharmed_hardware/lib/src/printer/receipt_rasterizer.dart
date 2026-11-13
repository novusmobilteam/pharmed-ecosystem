// pharmed-client/lib/core/hardware/printer/receipt_rasterizer.dart
//
// [SWREQ-PRN-010] [IEC 62304 §5.5]
// ReceiptDocument → yazıcıya gidecek parçalar.
//
// Metin, ayraç ve boşluk blokları Flutter'ın metin motoruyla (TextPainter)
// kâğıt genişliğinde bir tuvale çizilir ve 1-bit görüntüye çevrilir. Böylece
// Türkçe karakterler ve font seçimi yazıcının firmware'inden bağımsızdır.
// Barkod blokları görüntüye çizilmez; yazıcının yerel barkod komutuyla
// basılmak üzere ayrı parça olarak döner. Kodlanamayan barkod metin olarak çizilir.
//
// Önizleme modunda (mock yazıcı) barkodlar da görüntüye çerçeveli yer tutucu
// olarak çizilir ve sonuç PNG olarak alınır.
//
// Sınıf: Class B

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'esc_pos_encoder.dart';

sealed class RenderedPart {
  const RenderedPart();
}

final class RasterPart extends RenderedPart {
  const RasterPart(this.bitmap);
  final MonoBitmap bitmap;
}

final class BarcodePart extends RenderedPart {
  const BarcodePart(this.barcode, this.height);
  final EncodedBarcode barcode;
  final int height;
}

class ReceiptRasterizer {
  const ReceiptRasterizer({this.encoder = const EscPosEncoder(), this.blackThreshold = 160});

  final EscPosEncoder encoder;

  /// 0-255 arası parlaklık; altındaki pikseller siyah basılır. Kenar yumuşatmalı
  /// ince harflerin termal kâğıtta silik çıkmaması için 128'in biraz üstünde.
  final int blackThreshold;

  int get width => encoder.paperWidthDots;

  /// Tek görüntünün en fazla yüksekliği; uzun fişler birden fazla görüntüye bölünür
  /// (GPU doku sınırı ve bellek için).
  static const _maxImageHeight = 4096;

  // ── Tipografi ──────────────────────────────────────────────

  static double fontSizeOf(ReceiptTextSize size) => switch (size) {
    ReceiptTextSize.small => 20,
    ReceiptTextSize.normal => 22,
    ReceiptTextSize.large => 30,
    ReceiptTextSize.title => 56,
  };

  TextStyle _style(ReceiptTextSize size, bool bold) {
    final isTitle = size == ReceiptTextSize.title;
    return TextStyle(
      fontFamily: isTitle ? MedFonts.title : MedFonts.sans,
      fontSize: fontSizeOf(size),
      // DM Sans en fazla w600; normal metin w500 — termal kâğıtta w400 silik kalıyor.
      fontWeight: isTitle ? FontWeight.w700 : (bold ? FontWeight.w600 : FontWeight.w500),
      color: const Color(0xFF000000),
      height: 1.15,
    );
  }

  // ── Genel API ──────────────────────────────────────────────

  /// Yazdırma için: görüntü ve yerel barkod parçaları.
  Future<List<RenderedPart>> render(ReceiptDocument document) async {
    final parts = <RenderedPart>[];
    final run = <_Item>[];

    Future<void> flush() async {
      if (run.isEmpty) return;
      final image = await _paint(run);
      run.clear();
      try {
        parts.add(RasterPart(await _toMono(image)));
      } finally {
        image.dispose();
      }
    }

    for (final block in document.blocks) {
      if (block is ReceiptBarcode) {
        final encoded = encoder.encodeBarcode(block.data, block.type);
        if (encoded != null) {
          await flush();
          parts.add(BarcodePart(encoded, block.height));
          continue;
        }
      }
      for (final item in _layout(block, preview: false)) {
        if (_height(run) + item.height > _maxImageHeight) await flush();
        run.add(item);
      }
    }
    await flush();
    return parts;
  }

  /// Önizleme için: fişin PNG görüntüleri (uzun fişte birden fazla).
  Future<List<Uint8List>> renderPreviewPng(ReceiptDocument document) async {
    final pngs = <Uint8List>[];
    final run = <_Item>[];

    Future<void> flush() async {
      if (run.isEmpty) return;
      final image = await _paint(run);
      run.clear();
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data != null) pngs.add(data.buffer.asUint8List());
      } finally {
        image.dispose();
      }
    }

    for (final block in document.blocks) {
      for (final item in _layout(block, preview: true)) {
        if (_height(run) + item.height > _maxImageHeight) await flush();
        run.add(item);
      }
    }
    await flush();
    return pngs;
  }

  // ── Yerleşim ───────────────────────────────────────────────

  List<_Item> _layout(ReceiptBlock block, {required bool preview}) {
    return switch (block) {
      ReceiptText() => [_layoutText(block)],
      ReceiptKeyValue() => _layoutKeyValue(block),
      ReceiptDivider() => [_layoutDivider(block.style)],
      ReceiptSpacer() => [_Item(block.height.clamp(0, 400).toDouble(), (_, _) {})],
      ReceiptBarcode() => preview ? [_layoutBarcodePlaceholder(block)] : [_layoutBarcodeAsText(block)],
    };
  }

  _Item _layoutText(ReceiptText block) {
    final indent = block.indent.clamp(0, width ~/ 2).toDouble();
    final available = width - indent;
    final painter = TextPainter(
      text: TextSpan(text: block.text, style: _style(block.size, block.bold)),
      textDirection: TextDirection.ltr,
      textAlign: switch (block.align) {
        ReceiptAlign.left => TextAlign.left,
        ReceiptAlign.center => TextAlign.center,
        ReceiptAlign.right => TextAlign.right,
      },
    )..layout(minWidth: available, maxWidth: available);
    return _Item(painter.height.ceilToDouble(), (canvas, top) {
      painter.paint(canvas, Offset(indent, top));
    });
  }

  List<_Item> _layoutKeyValue(ReceiptKeyValue block) {
    const gap = 12.0;
    final indent = block.indent.clamp(0, width ~/ 2).toDouble();
    final available = width - indent;
    final style = _style(block.size, block.bold);

    final right = TextPainter(
      text: TextSpan(text: block.value, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    )..layout(maxWidth: available);
    final left = TextPainter(
      text: TextSpan(text: block.label, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: available);

    final fitsOneLine =
        left.computeLineMetrics().length == 1 &&
        right.computeLineMetrics().length == 1 &&
        left.width + gap + right.width <= available;

    if (fitsOneLine) {
      final h = (left.height > right.height ? left.height : right.height).ceilToDouble();
      return [
        _Item(h, (canvas, top) {
          left.paint(canvas, Offset(indent, top));
          right.paint(canvas, Offset(width - right.width, top));
        }),
      ];
    }

    // Sığmıyor: etiket kendi satırında, değer alt satırda sağa yaslı.
    right.layout(minWidth: available, maxWidth: available);
    return [
      _Item(left.height.ceilToDouble(), (canvas, top) => left.paint(canvas, Offset(indent, top))),
      _Item(right.height.ceilToDouble(), (canvas, top) => right.paint(canvas, Offset(indent, top))),
    ];
  }

  _Item _layoutDivider(ReceiptDividerStyle style) {
    const pad = 6.0;
    final thickness = style == ReceiptDividerStyle.thick ? 4.0 : 2.0;
    return _Item(pad * 2 + thickness, (canvas, top) {
      final paint = Paint()..color = const Color(0xFF000000);
      final y = top + pad;
      if (style == ReceiptDividerStyle.dashed) {
        for (var x = 0.0; x < width; x += 10) {
          canvas.drawRect(Rect.fromLTWH(x, y, 6, thickness), paint);
        }
      } else {
        canvas.drawRect(Rect.fromLTWH(0, y, width.toDouble(), thickness), paint);
      }
    });
  }

  /// Yazıcının basamadığı barkod: verisi okunabilir metin olarak basılır.
  _Item _layoutBarcodeAsText(ReceiptBarcode block) =>
      _layoutText(ReceiptText(block.data, align: ReceiptAlign.center, bold: true));

  _Item _layoutBarcodePlaceholder(ReceiptBarcode block) {
    final label = TextPainter(
      text: TextSpan(
        text: '${block.type.name.toUpperCase()}  ${block.data}',
        style: _style(ReceiptTextSize.small, false),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(minWidth: width - 40, maxWidth: width - 40);
    final h = block.height.toDouble() + label.height + 8;
    return _Item(h, (canvas, top) {
      final frame = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(Rect.fromLTWH(20, top + 1, width - 40.0, block.height.toDouble()), frame);
      label.paint(canvas, Offset(20, top + block.height + 4));
    });
  }

  // ── Çizim ve 1-bit dönüşüm ─────────────────────────────────

  double _height(List<_Item> items) => items.fold(0, (sum, i) => sum + i.height);

  Future<ui.Image> _paint(List<_Item> items) async {
    final height = _height(items).ceil().clamp(1, _maxImageHeight);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    var top = 0.0;
    for (final item in items) {
      item.paint(canvas, top);
      top += item.height;
    }
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(width, height);
    } finally {
      picture.dispose();
    }
  }

  Future<MonoBitmap> _toMono(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) {
      throw const PrinterException(message: 'Fiş görüntüsü okunamadı', reason: PrinterFailureReason.renderFailed);
    }
    final rgba = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final widthBytes = (image.width + 7) ~/ 8;
    final bits = Uint8List(widthBytes * image.height);

    for (var y = 0; y < image.height; y++) {
      final rowIn = y * image.width * 4;
      final rowOut = y * widthBytes;
      for (var x = 0; x < image.width; x++) {
        final i = rowIn + x * 4;
        // Siyah-beyaz çizim: kanallar eşit; yine de saydamlığı beyaz üzerine kat.
        final a = rgba[i + 3];
        final lum = (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;
        final onWhite = (lum * a + 255 * (255 - a)) ~/ 255;
        if (onWhite < blackThreshold) {
          bits[rowOut + (x >> 3)] |= 0x80 >> (x & 7);
        }
      }
    }
    return MonoBitmap(widthBytes: widthBytes, height: image.height, bits: bits);
  }
}

typedef _PaintFn = void Function(Canvas canvas, double top);

final class _Item {
  const _Item(this.height, this.paint);
  final double height;
  final _PaintFn paint;
}
