// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'need.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NeedAdapter extends TypeAdapter<Need> {
  @override
  final int typeId = 7;

  @override
  Need read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Need(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      estimatedCost: fields[3] as double,
      status: fields[4] as String,
      date: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Need obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.estimatedCost)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NeedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
