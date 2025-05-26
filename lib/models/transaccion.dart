import 'package:hive/hive.dart';
import 'package:finance_control/models/categoria.dart';

part 'transaccion.g.dart';

@HiveType(typeId: 2)
class Transaccion {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final double monto;

  @HiveField(2)
  final String descripcion;

  @HiveField(3)
  final DateTime fecha;

  @HiveField(4)
  final Categoria categoria;

  Transaccion({
    required this.id,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    required this.categoria,
  });

  TipoTransaccion get tipo => categoria.tipo;
}
