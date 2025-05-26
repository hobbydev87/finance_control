import 'package:hive/hive.dart';

part 'categoria.g.dart';

@HiveType(typeId: 0)
class Categoria {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final TipoTransaccion tipo;

  Categoria({
    required this.id,
    required this.nombre,
    required this.tipo,
  });
}

@HiveType(typeId: 1)
enum TipoTransaccion {
  @HiveField(0)
  ingreso,
  @HiveField(1)
  gasto,
}
