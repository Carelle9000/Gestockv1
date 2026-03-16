// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplierAdapter extends TypeAdapter<Supplier> {
  @override
  final int typeId = 2;

  @override
  Supplier read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Supplier(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      address: fields[3] as String,
      email: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Supplier obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
