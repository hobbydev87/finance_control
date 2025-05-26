// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaccion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransaccionAdapter extends TypeAdapter<Transaccion> {
  @override
  final int typeId = 2;

  @override
  Transaccion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaccion(
      id: fields[0] as int,
      monto: fields[1] as double,
      descripcion: fields[2] as String,
      fecha: fields[3] as DateTime,
      categoria: fields[4] as Categoria,
    );
  }

  @override
  void write(BinaryWriter writer, Transaccion obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.monto)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.fecha)
      ..writeByte(4)
      ..write(obj.categoria);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransaccionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
