// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categoria.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoriaAdapter extends TypeAdapter<Categoria> {
  @override
  final int typeId = 0;

  @override
  Categoria read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Categoria(
      id: fields[0] as int,
      nombre: fields[1] as String,
      tipo: fields[2] as TipoTransaccion,
    );
  }

  @override
  void write(BinaryWriter writer, Categoria obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.tipo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TipoTransaccionAdapter extends TypeAdapter<TipoTransaccion> {
  @override
  final int typeId = 1;

  @override
  TipoTransaccion read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipoTransaccion.ingreso;
      case 1:
        return TipoTransaccion.gasto;
      default:
        return TipoTransaccion.ingreso;
    }
  }

  @override
  void write(BinaryWriter writer, TipoTransaccion obj) {
    switch (obj) {
      case TipoTransaccion.ingreso:
        writer.writeByte(0);
        break;
      case TipoTransaccion.gasto:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipoTransaccionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
