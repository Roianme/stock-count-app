import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:universal_html/html.dart' as html;
import '../model/category_model.dart';
import '../model/item_model.dart';

/// Full data backup/restore service for protecting against browser
/// cache clearing (which wipes IndexedDB where Hive lives).
class BackupService {
  static String exportToJson({
    required List<Item> items,
    required List<CategoryRecord> categories,
    required Map<String, dynamic> metadata,
  }) {
    final backup = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'items': items.map(_itemToJson).toList(),
      'categories': categories.map(_categoryToJson).toList(),
      'metadata': metadata,
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  static BackupData importFromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final backupVersion = map['version'] as int? ?? 1;
    final items = (map['items'] as List<dynamic>)
        .map((e) => _itemFromJson(e as Map<String, dynamic>))
        .toList();
    final categories = (map['categories'] as List<dynamic>)
        .map((e) => _categoryFromJson(e as Map<String, dynamic>))
        .toList();
    final metadata = map['metadata'] as Map<String, dynamic>? ?? {};
    return BackupData(
      items: items, categories: categories,
      metadata: metadata, backupVersion: backupVersion,
    );
  }

  static void downloadBackup(String json,
      {String filename = 'stock_count_backup.json'}) {
    if (!kIsWeb) return;
    final bytes = utf8.encode(json);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static Future<BackupData?> pickAndParseBackup() async {
    if (!kIsWeb) return null;
    final completer = Completer<BackupData?>();
    final input = html.FileUploadInputElement()
      ..accept = '.json'
      ..click();
    input.onChange.listen((_) async {
      final file = input.files?.firstOrNull;
      if (file == null) { completer.complete(null); return; }
      try {
        final reader = html.FileReader();
        reader.readAsText(file);
        reader.onLoad.first.then((_) {
          try {
            completer.complete(importFromJson(reader.result as String));
          } catch (e) {
            debugPrint('Backup parse error: $e');
            completer.complete(null);
          }
        });
        reader.onError.first.then((_) => completer.complete(null));
      } catch (e) {
        debugPrint('Backup file read error: $e');
        completer.complete(null);
      }
    });
    return completer.future;
  }

  // ---- Serialization ----

  static Map<String, dynamic> _itemToJson(Item item) => {
    'id': item.id, 'name': item.name,
    'category': item.category.index,
    'status': item.status.index,
    'isChecked': item.isChecked,
    'quantity': item.quantity,
    'modes': item.modes.map((m) => m.index).toList(),
    'unit': item.unit,
    'unitOptions': item.unitOptions
        .map((o) => {'label': o.label, 'isUrgent': o.isUrgent}).toList(),
    'categoryId': item.categoryId,
    'enabledStatuses': item.enabledStatuses.map((s) => s.index).toList(),
  };

  static Item _itemFromJson(Map<String, dynamic> json) => Item(
    id: json['id'] as int,
    name: json['name'] as String,
    category: Category.values[json['category'] as int],
    status: ItemStatus.values[json['status'] as int],
    isChecked: json['isChecked'] as bool? ?? false,
    quantity: json['quantity'] as int?,
    modes: (json['modes'] as List<dynamic>?)
        ?.map((m) => Mode.values[m as int]).toSet() ?? const {Mode.city},
    unit: json['unit'] as String?,
    unitOptions: (json['unitOptions'] as List<dynamic>?)
        ?.map((o) => ItemUnitOptionRecord(
              label: (o as Map<String, dynamic>)['label'] as String,
              isUrgent: (o)['isUrgent'] as bool? ?? false))
        .toList() ?? const [],
    categoryId: json['categoryId'] as String?,
    enabledStatuses: (json['enabledStatuses'] as List<dynamic>?)
        ?.map((s) => ItemStatus.values[s as int]).toSet()
        ?? const {ItemStatus.quantity},
  );

  static Map<String, dynamic> _categoryToJson(CategoryRecord cat) => {
    'id': cat.id, 'name': cat.name,
    'colorValue': cat.colorValue,
    'iconCodePoint': cat.iconCodePoint,
    'iconFontFamily': cat.iconFontFamily,
    'sortOrder': cat.sortOrder,
  };

  static CategoryRecord _categoryFromJson(Map<String, dynamic> json) =>
    CategoryRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int,
      iconCodePoint: json['iconCodePoint'] as int,
      iconFontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
      sortOrder: json['sortOrder'] as int,
    );
}

class BackupData {
  final List<Item> items;
  final List<CategoryRecord> categories;
  final Map<String, dynamic> metadata;
  final int backupVersion;
  const BackupData({
    required this.items, required this.categories,
    required this.metadata, required this.backupVersion,
  });
}