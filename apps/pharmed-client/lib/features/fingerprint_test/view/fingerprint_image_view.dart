// pharmed-client/lib/features/fingerprint_test/view/fingerprint_image_view.dart
//
// Okuyucudan gelen 8 bit gri tonlamalı ham görüntüyü çizer.
// Görüntü yalnızca bellekte tutulur; diske yazılmaz (KVKK).

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class FingerprintImageView extends StatefulWidget {
  const FingerprintImageView({super.key, required this.image, this.placeholder});

  final FingerprintImage? image;
  final String? placeholder;

  @override
  State<FingerprintImageView> createState() => _FingerprintImageViewState();
}

class _FingerprintImageViewState extends State<FingerprintImageView> {
  ui.Image? _decoded;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(covariant FingerprintImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.image, widget.image)) _decode();
  }

  void _decode() {
    final image = widget.image;
    final generation = ++_generation;
    if (image == null || image.pixels.length < image.width * image.height) {
      if (_decoded != null) _setDecoded(null);
      return;
    }

    // Gri → RGBA (decodeImageFromPixels gri formatı desteklemiyor).
    final rgba = Uint8List(image.width * image.height * 4);
    for (var i = 0, j = 0; i < image.width * image.height; i++, j += 4) {
      final v = image.pixels[i];
      rgba[j] = v;
      rgba[j + 1] = v;
      rgba[j + 2] = v;
      rgba[j + 3] = 255;
    }
    ui.decodeImageFromPixels(rgba, image.width, image.height, ui.PixelFormat.rgba8888, (decoded) {
      if (!mounted || generation != _generation) {
        decoded.dispose(); // daha yeni bir görüntü gelmiş
        return;
      }
      _setDecoded(decoded);
    });
  }

  void _setDecoded(ui.Image? next) {
    if (!mounted) {
      next?.dispose();
      return;
    }
    final old = _decoded;
    setState(() => _decoded = next);
    old?.dispose();
  }

  @override
  void dispose() {
    _decoded?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoded = _decoded;
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.lgAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: decoded == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fingerprint, size: 72, color: MedColors.text4),
                  const SizedBox(height: MedSpacing.md),
                  Text(
                    widget.placeholder ?? 'Görüntü yok',
                    textAlign: TextAlign.center,
                    style: MedTextStyles.bodySm(color: MedColors.text3),
                  ),
                ],
              ),
            )
          : Padding(
              padding: MedSpacing.insetMd,
              child: RawImage(image: decoded, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
            ),
    );
  }
}
