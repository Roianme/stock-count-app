import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../model/item_model.dart';
import 'export_service_base.dart';
import 'export_service_mobile.dart';
import 'export_service_web.dart';

/// Factory that provides the correct export service based on platform
class ExportService {
  static final ExportServiceBase _instance = _createInstance();

  static ExportServiceBase _createInstance() {
    if (kIsWeb) {
      return WebExportService();
    } else {
      return MobileExportService();
    }
  }

  static ExportServiceBase get instance => _instance;

  /// Convenience static methods that delegate to the platform-specific instance
  static Future<bool> exportAndShare(
    BuildContext context,
    List<Item> items, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) {
    return _instance.exportAndShare(
      context,
      items,
      title: title,
      location: location,
      name: name,
    );
  }

  static Future<String?> saveToDevice(
    BuildContext context,
    List<Item> items, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) {
    return _instance.saveToDevice(
      context,
      items,
      title: title,
      location: location,
      name: name,
    );
  }

  static Future<dynamic> generateReportImage(
    BuildContext context,
    List<Item> items, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) {
    return _instance.generateReportImage(
      context,
      items,
      title: title,
      location: location,
      name: name,
    );
  }

  /// Export arbitrary PNG bytes using platform-specific sharing/downloading.
  static Future<bool> exportImageBytes(
    BuildContext context,
    Uint8List imageBytes, {
    String filename = 'export.png',
    String? title,
    String? description,
  }) {
    return _instance.exportImageBytes(
      context,
      imageBytes,
      filename: filename,
      title: title,
      description: description,
    );
  }
}
