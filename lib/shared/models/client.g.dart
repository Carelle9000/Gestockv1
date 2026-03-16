// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClientAdapter extends TypeAdapter<Client> {
  @override
  final int typeId = 1;

  @override
  Client read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Client(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      address: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
