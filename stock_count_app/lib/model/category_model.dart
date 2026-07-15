import 'package:hive/hive.dart';
import 'item_model.dart';

class CategoryRecord {
  final String id;
  final String name;
  final int colorValue;
  final int iconCodePoint;
  final String iconFontFamily;
  final int sortOrder;

  const CategoryRecord({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    required this.sortOrder,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryRecord && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

}

class CategoryRecordAdapter extends TypeAdapter<CategoryRecord> {
  @override
  final int typeId = 5;

  @override
  CategoryRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryRecord(
      id: fields[0] as String,
      name: fields[1] as String,
      colorValue: fields[2] as int,
      iconCodePoint: fields[3] as int,
      iconFontFamily: fields[4] as String? ?? 'MaterialIcons',
      sortOrder: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.iconCodePoint)
      ..writeByte(4)
      ..write(obj.iconFontFamily)
      ..writeByte(5)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

String categoryRecordIdFor(Category category) {
  return category.name;
}

Future<void> ensureDefaultCategoriesSeeded(Box<CategoryRecord> box) async {
  if (box.isNotEmpty) return;

  final Map<String, CategoryRecord> newRecords = {};
  int index = 0;
  for (final category in Category.values) {
    final record = CategoryRecord(
      id: categoryRecordIdFor(category),
      name: category.displayName,
      // ignore: deprecated_member_use
      colorValue: category.color.value,
      iconCodePoint: category.icon.codePoint,
      iconFontFamily: category.icon.fontFamily ?? 'MaterialIcons',
      sortOrder: index,
    );
    newRecords[record.id] = record;
    index++;
  }

  await box.putAll(newRecords);
}
