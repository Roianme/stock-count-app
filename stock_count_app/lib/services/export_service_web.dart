import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:universal_html/html.dart' as html;
import '../model/item_model.dart';
import '../view/report_widget.dart';
import 'export_service_base.dart';

/// Web-specific export service
/// Uses browser download and share capabilities
class WebExportService extends ExportServiceBase {
  @override
  Future<bool> exportAndShare(
    BuildContext context,
    List<Item> checkedItems, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) async {
    try {
      final image = await generateReportImage(
        context,
        checkedItems,
        title: title,
        location: location,
        name: name,
      );

      if (image == null) {
        return false;
      }

      // Try Web Share API if available, otherwise fall back to download
      try {
        // Web Share API (limited support, requires HTTPS and user gesture)
        final blob = html.Blob([image], 'image/png');
        final file = html.File(
          [blob],
          'stock_report.png',
          {'type': 'image/png'},
        );
        await html.window.navigator.share({
          'title': title,
          'text': 'Stock Count Report',
          'files': [file],
        });
        return true;
      } catch (e) {
        debugPrint('Web Share failed, falling back to download: $e');
        // Fall through to download
      }

      // Download the image
      _downloadImage(image, 'stock_report.png');
      return true;
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }

  @override
  Future<String?> saveToDevice(
    BuildContext context,
    List<Item> checkedItems, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) async {
    try {
      final image = await generateReportImage(
        context,
        checkedItems,
        title: title,
        location: location,
        name: name,
      );

      if (image == null) {
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _downloadImage(image, 'stock_report_$timestamp.png');

      return 'Report downloaded successfully';
    } catch (e) {
      debugPrint('Save error: $e');
      return null;
    }
  }

  @override
  Future<Uint8List?> generateReportImage(
    BuildContext context,
    List<Item> checkedItems, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) async {
    return _captureReportWidget(
      context,
      checkedItems,
      title: title,
      location: location,
      name: name,
    );
  }

  /// Capture report widget as image using overlay
  Future<Uint8List?> _captureReportWidget(
    BuildContext context,
    List<Item> checkedItems, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
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
              height: 1800,
              color: Colors.white,
              child: RepaintBoundary(
                key: boundary,
                child: ReportWidget(
                  checkedItems: checkedItems,
                  title: title,
                  location: location,
                  name: name,
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
      debugPrint('Capture error: $e');
      return null;
    }
  }

  /// Trigger download in browser
  void _downloadImage(Uint8List imageData, String filename) {
    final blob = html.Blob([imageData], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
