// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleItemAdapter extends TypeAdapter<SaleItem> {
  @override
  final int typeId = 4;

  @override
  SaleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItem(
      id: fields[0] as String,
      saleId: fields[1] as String,
      productId: fields[2] as String,
      quantity: fields[3] as int,
      price: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SaleItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.saleId)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
