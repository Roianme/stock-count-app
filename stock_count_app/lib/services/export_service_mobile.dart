import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../model/item_model.dart';
import '../view/report_widget.dart';
import 'export_service_base.dart';

/// Mobile-specific export service (Android, iOS, etc.)
/// Uses gallery access and file sharing
class MobileExportService extends ExportServiceBase {
  @override
  Future<bool> exportAndShare(
    BuildContext context,
    List<Item> checkedItems, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) async {
    try {
      // Render widget to image using overlay
      final image = await _captureReportWidget(
        context,
        checkedItems,
        title: title,
        location: location,
        name: name,
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

  @override
  Future<String?> saveToDevice(
    BuildContext context,
    List<Item> checkedItems, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) async {
    try {
      print('Starting save to device...');

      // Render widget to image using overlay
      final image = await _captureReportWidget(
        context,
        checkedItems,
        title: title,
        location: location,
        name: name,
      );

      if (image == null) {
        print('Failed to capture image');
        return null;
      }

      print('Image captured, size: ${image.length} bytes');

      // Save directly to gallery using Gal
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'stock_report_$timestamp.png';

      await Gal.putImageBytes(
        image,
        album: 'Stock Count Reports',
        name: fileName,
      );

      print('Successfully saved to gallery: Stock Count Reports/$fileName');
      return 'Saved to Gallery: Stock Count Reports';
    } catch (e, stackTrace) {
      print('Save error: $e');
      print('Stack trace: $stackTrace');
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
      print('Capture error: $e');
      return null;
    }
  }
}
