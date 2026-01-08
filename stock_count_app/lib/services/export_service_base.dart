import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../model/item_model.dart';

/// Abstract export service that both mobile and web implementations follow
abstract class ExportServiceBase {
  /// Generate report image and share it
  Future<bool> exportAndShare(
    BuildContext context,
    List<Item> items, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  });

  /// Save report directly to device storage (or equivalent)
  Future<String?> saveToDevice(
    BuildContext context,
    List<Item> items, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  });

  /// Generate report image without saving or sharing
  Future<Uint8List?> generateReportImage(
    BuildContext context,
    List<Item> items, {
    String title = 'Stock Count Report',
    String? location,
    String? name,
  });
}
