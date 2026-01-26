// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 2;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      id: fields[0] as int?,
      name: fields[1] as String?,
      category: fields[2] as Category?,
      status: fields[3] as ItemStatus?,
      isChecked: fields[4] as bool,
      quantity: fields[5] as int,
      unit: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.isChecked)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemStatusAdapter extends TypeAdapter<ItemStatus> {
  @override
  final int typeId = 0;

  @override
  ItemStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemStatus.quantity;
      case 1:
        return ItemStatus.quantity;
      case 2:
        return ItemStatus.quantity;
      case 3:
        return ItemStatus.urgent;
      case 4:
        return ItemStatus.quantity;
      default:
        return ItemStatus.quantity;
    }
  }

  @override
  void write(BinaryWriter writer, ItemStatus obj) {
    switch (obj) {
      case ItemStatus.urgent:
        writer.writeByte(3);
        break;
      case ItemStatus.quantity:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1;

  @override
  Category read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Category.bbqGrill;
      case 1:
        return Category.warehouse;
      case 2:
        return Category.essentials;
      case 3:
        return Category.spices;
      case 4:
        return Category.rawItems;
      case 5:
        return Category.drinks;
      case 6:
        return Category.misc;
      case 7:
        return Category.supplier;
      case 8:
        return Category.produce;
      case 9:
        return Category.filipinoSupplier;
      case 10:
        return Category.colesWoolies;
      case 11:
        return Category.chemicals;
      case 12:
        return Category.dessert;
      default:
        return Category.bbqGrill;
    }
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    switch (obj) {
      case Category.bbqGrill:
        writer.writeByte(0);
        break;
      case Category.warehouse:
        writer.writeByte(1);
        break;
      case Category.essentials:
        writer.writeByte(2);
        break;
      case Category.spices:
        writer.writeByte(3);
        break;
      case Category.rawItems:
        writer.writeByte(4);
        break;
      case Category.drinks:
        writer.writeByte(5);
        break;
      case Category.misc:
        writer.writeByte(6);
        break;
      case Category.supplier:
        writer.writeByte(7);
        break;
      case Category.produce:
        writer.writeByte(8);
        break;
      case Category.filipinoSupplier:
        writer.writeByte(9);
        break;
      case Category.colesWoolies:
        writer.writeByte(10);
        break;
      case Category.chemicals:
        writer.writeByte(11);
        break;
      case Category.dessert:
        writer.writeByte(12);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
