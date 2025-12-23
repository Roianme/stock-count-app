import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../model/item_model.dart';
import '../view/report_widget.dart';

class ExportService {
  /// Generate report image and share it using overlay screenshot
  static Future<bool> exportAndShare(
    BuildContext context,
    List<Item> checkedItems, {
    String title = 'Stock Count Report',
    String? location,
  }) async {
    try {
      // Render widget to image using overlay
      final image = await _captureReportWidget(
        context,
        checkedItems,
        title: title,
        location: location,
      );

      if (image == null) {
        return false;
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/stock_report_$timestamp.png');
      await file.writeAsBytes(image);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: title, subject: title);

      return true;
    } catch (e) {
      print('Export error: $e');
      return false;
    }
  }

  /// Capture report widget as image using overlay
  static Future<Uint8List?> _captureReportWidget(
    BuildContext context,
    List<Item> checkedItems, {
    String title = 'Stock Count Report',
    String? location,
  }) async {
    try {
      final boundary = GlobalKey();
      OverlayEntry? overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000,
          top: -10000,
          child: Material(
            child: Container(
              width: 1200,
              height: 1600,
              color: Colors.white,
              child: RepaintBoundary(
                key: boundary,
                child: ReportWidget(
                  checkedItems: checkedItems,
                  title: title,
                  location: location,
                ),
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(overlayEntry);
      await Future.delayed(const Duration(milliseconds: 500));

      final renderObject =
          boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (renderObject == null) {
        overlayEntry.remove();
        return null;
      }

      final image = await renderObject.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      overlayEntry.remove();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Capture error: $e');
      return null;
    }
  }
}
