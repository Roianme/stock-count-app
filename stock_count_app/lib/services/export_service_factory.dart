import 'package:flutter/foundation.dart';
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
    context,
    checkedItems, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) {
    return _instance.exportAndShare(
      context,
      checkedItems,
      title: title,
      location: location,
      name: name,
    );
  }

  static Future<String?> saveToDevice(
    context,
    checkedItems, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) {
    return _instance.saveToDevice(
      context,
      checkedItems,
      title: title,
      location: location,
      name: name,
    );
  }

  static Future<dynamic> generateReportImage(
    context,
    checkedItems, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  }) {
    return _instance.generateReportImage(
      context,
      checkedItems,
      title: title,
      location: location,
      name: name,
    );
  }
}
