import 'package:flutter/material.dart';
import 'package:finance_control/models/categoria.dart';
import 'package:finance_control/models/transaccion.dart';

class NuevaTransaccionPage extends StatefulWidget {
  final List<Categoria> categoriasDisponibles;
  final Transaccion? transaccionExistente;

  const NuevaTransaccionPage({
    super.key,
    required this.categoriasDisponibles,
    this.transaccionExistente,
  });

  @override
  State<NuevaTransaccionPage> createState() => _NuevaTransaccionPageState();
}

class _NuevaTransaccionPageState extends State<NuevaTransaccionPage> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();

  DateTime _fecha = DateTime.now();
  Categoria? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    if (widget.transaccionExistente != null) {
      final t = widget.transaccionExistente!;
      _descripcionController.text = t.descripcion;
      _montoController.text = t.monto.toString();
      _fecha = t.fecha;

      // Buscar la instancia de categoría equivalente por ID
      final match = widget.categoriasDisponibles.firstWhere(
        (cat) => cat.id == t.categoria.id,
        orElse: () => widget.categoriasDisponibles.first,
      );
      _categoriaSeleccionada = match;
    }
  }

  void _guardarTransaccion() {
    if (_formKey.currentState!.validate() && _categoriaSeleccionada != null) {
      final nueva = Transaccion(
        id: widget.transaccionExistente?.id ?? DateTime.now().millisecondsSinceEpoch & 0xFFFFFFFF,
        monto: double.parse(_montoController.text),
        descripcion: _descripcionController.text,
        fecha: _fecha,
        categoria: _categoriaSeleccionada!,
      );

      Navigator.pop(context, nueva);
    }
  }

  void _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fecha) {
      setState(() {
        _fecha = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaccionExistente == null
            ? 'Nueva Transacción'
            : 'Editar Transacción'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(labelText: 'Monto (€)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || double.tryParse(value) == null
                    ? 'Introduce un monto válido'
                    : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Fecha: ${_fecha.day}/${_fecha.month}/${_fecha.year}'),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _seleccionarFecha, child: const Text('Cambiar Fecha')),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Categoria>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: widget.categoriasDisponibles.map((categoria) {
                  return DropdownMenuItem<Categoria>(
                    value: categoria,
                    child: Text(categoria.nombre),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _categoriaSeleccionada = value),
                validator: (value) => value == null ? 'Selecciona una categoría' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _guardarTransaccion,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
