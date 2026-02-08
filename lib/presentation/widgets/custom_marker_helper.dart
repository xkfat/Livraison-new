import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';

class CustomMarkerHelper {
  static final Map<String, BitmapDescriptor> _cache = {};

  /// Create a truck marker from PNG asset
  static Future<BitmapDescriptor> createTruckMarker({
    double size = 80,
  }) async {
    final String cacheKey = 'truck_$size';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final ByteData data = await rootBundle.load('assets/images/truckk.png');
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: size.toInt(),
        targetHeight: size.toInt(),
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ByteData? byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final marker = BitmapDescriptor.fromBytes(pngBytes);
      _cache[cacheKey] = marker;

      return marker;
    } catch (e) {
      print('Error creating truck marker: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  /// Create a package icon marker with background (for tracking screen)
  static Future<BitmapDescriptor> createPackageMarker({
    Color color = AppColors.statusEnAttente,
    double size = 100,
  }) async {
    final String cacheKey = 'package_${color.value}_$size';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;

      final double circleSize = size * 0.8;

      // Draw shadow
      paint.color = Colors.black.withOpacity(0.3);
      canvas.drawCircle(
        Offset(size / 2 + 2, size / 2 + 2),
        circleSize / 2,
        paint,
      );

      // Draw white background circle
      paint.color = Colors.white;
      canvas.drawCircle(
        Offset(size / 2, size / 2),
        circleSize / 2,
        paint,
      );

      // Draw colored border
      paint.color = color;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 4;
      canvas.drawCircle(
        Offset(size / 2, size / 2),
        circleSize / 2 - 2,
        paint,
      );

      // Draw package icon
      paint.style = PaintingStyle.fill;
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.inventory_2_rounded.codePoint),
          style: TextStyle(
            fontSize: size * 0.45,
            fontFamily: Icons.inventory_2_rounded.fontFamily,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size - textPainter.width) / 2,
          (size - textPainter.height) / 2,
        ),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final marker = BitmapDescriptor.fromBytes(pngBytes);
      _cache[cacheKey] = marker;

      return marker;
    } catch (e) {
      print('Error creating package marker: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  /// Create a destination pin marker with background
  static Future<BitmapDescriptor> createDestinationMarker({
    Color color = AppColors.success,
    double size = 100,
  }) async {
    final String cacheKey = 'destination_${color.value}_$size';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;

      final double circleSize = size * 0.8;

      // Draw shadow
      paint.color = Colors.black.withOpacity(0.3);
      canvas.drawCircle(
        Offset(size / 2 + 2, size / 2 + 2),
        circleSize / 2,
        paint,
      );

      // Draw white background circle
      paint.color = Colors.white;
      canvas.drawCircle(
        Offset(size / 2, size / 2),
        circleSize / 2,
        paint,
      );

      // Draw colored border
      paint.color = color;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 4;
      canvas.drawCircle(
        Offset(size / 2, size / 2),
        circleSize / 2 - 2,
        paint,
      );

      // Draw location icon
      paint.style = PaintingStyle.fill;
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.location_on_rounded.codePoint),
          style: TextStyle(
            fontSize: size * 0.5,
            fontFamily: Icons.location_on_rounded.fontFamily,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size - textPainter.width) / 2,
          (size - textPainter.height) / 2,
        ),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final marker = BitmapDescriptor.fromBytes(pngBytes);
      _cache[cacheKey] = marker;

      return marker;
    } catch (e) {
      print('Error creating destination marker: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  static void clearCache() {
    _cache.clear();
  }
}