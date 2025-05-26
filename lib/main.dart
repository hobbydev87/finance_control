import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:finance_control/models/categoria.dart';
import 'package:finance_control/models/transaccion.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'pages/nueva_transaccion_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(CategoriaAdapter());
  Hive.registerAdapter(TipoTransaccionAdapter());
  Hive.registerAdapter(TransaccionAdapter());
  await Hive.openBox<Categoria>('categorias');
  await Hive.openBox<Transaccion>('transacciones');

  runApp(FinanceApp());
}

class FinanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Finanzas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Transaccion> _transacciones = [];
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    final transBox = Hive.box<Transaccion>('transacciones');
    final catBox = Hive.box<Categoria>('categorias');
    _transacciones = transBox.values.toList();
    _categorias = catBox.values.toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _abrirNuevaTransaccion() async {
    final nueva = await Navigator.push<Transaccion>(
      context,
      MaterialPageRoute(
        builder: (_) => NuevaTransaccionPage(categoriasDisponibles: _categorias),
      ),
    );
    if (nueva != null) {
      setState(() {
        final idSeguro = nueva.id & 0xFFFFFFFF;
        _transacciones.add(nueva);
        Hive.box<Transaccion>('transacciones').put(idSeguro, nueva);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transacción añadida')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TransactionListPage(transacciones: _transacciones),
      SummaryPage(transacciones: _transacciones),
      HistoryPage(transacciones: _transacciones),
      CategoriesPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Presupuesto'),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transacciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorías',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNuevaTransaccion,
        child: Icon(Icons.add),
      ),
    );
  }
}

// El resto del código permanece igual (TransactionListPage, SummaryPage, HistoryPage, CategoriaManagerPage...)

// TransactionListPage
class TransactionListPage extends StatefulWidget {
  final List<Transaccion> transacciones;

  const TransactionListPage({Key? key, required this.transacciones}) : super(key: key);

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.transacciones.isEmpty) {
      return Center(child: Text('No hay transacciones aún'));
    }

    return ListView.builder(
      itemCount: widget.transacciones.length,
      itemBuilder: (context, index) {
        final t = widget.transacciones[index];
        final idSeguro = t.id & 0xFFFFFFFF;
        return Dismissible(
          key: Key(t.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('¿Eliminar transacción?'),
                content: Text('¿Estás seguro de que quieres eliminar esta transacción?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ) ?? false;
          },
          onDismissed: (direction) {
            setState(() {
              Hive.box<Transaccion>('transacciones').delete(idSeguro);
              widget.transacciones.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Transacción eliminada')),
            );
          },
          child: ListTile(
            onTap: () async {
              final transaccionEditada = await Navigator.push<Transaccion>(
                context,
                MaterialPageRoute(
                  builder: (_) => NuevaTransaccionPage(
                    categoriasDisponibles: Hive.box<Categoria>('categorias').values.toList(),
                    transaccionExistente: t,
                  ),
                ),
              );
              if (transaccionEditada != null) {
                setState(() {
                  widget.transacciones[index] = transaccionEditada;
                  Hive.box<Transaccion>('transacciones').put(transaccionEditada.id & 0xFFFFFFFF, transaccionEditada);
                });
              }
            },
            title: Text(t.descripcion),
            subtitle: Text('${t.categoria.nombre} • ${t.fecha.toLocal().toString().split(" ")[0]}'),
            trailing: Text('${t.monto.toStringAsFixed(2)} €'),
          ),
        );
      },
    );
  }
}


// SummaryPage
class SummaryPage extends StatelessWidget {
  final List<Transaccion> transacciones;

  const SummaryPage({Key? key, required this.transacciones}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ingresos = transacciones.where((t) => t.tipo == TipoTransaccion.ingreso).fold(0.0, (sum, t) => sum + t.monto);
    final gastos = transacciones.where((t) => t.tipo == TipoTransaccion.gasto).fold(0.0, (sum, t) => sum + t.monto);
    final balance = ingresos - gastos;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Resumen del Mes', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.arrow_downward, color: Colors.green),
              title: Text('Ingresos'),
              trailing: Text('${ingresos.toStringAsFixed(2)} €'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.arrow_upward, color: Colors.red),
              title: Text('Gastos'),
              trailing: Text('${gastos.toStringAsFixed(2)} €'),
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(
              '${balance.toStringAsFixed(2)} €',
              style: TextStyle(
                color: balance >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// HistoryPage
class HistoryPage extends StatelessWidget {
  final List<Transaccion> transacciones;

  const HistoryPage({Key? key, required this.transacciones}) : super(key: key);

  Map<String, double> calcularBalanceMensual(List<Transaccion> transacciones) {
    final Map<String, double> balances = {};
    for (var t in transacciones) {
      final mes = DateFormat('yyyy-MM').format(t.fecha);
      final valor = t.tipo == TipoTransaccion.ingreso ? t.monto : -t.monto;
      balances.update(mes, (v) => v + valor, ifAbsent: () => valor);
    }
    return Map.fromEntries(balances.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  @override
  Widget build(BuildContext context) {
    final balances = calcularBalanceMensual(transacciones);
    final meses = balances.keys.toList();
    final datos = balances.values.toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Histórico de Balance Mensual', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: List.generate(meses.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: datos[i],
                        width: 20,
                        color: datos[i] >= 0 ? Colors.green : Colors.red,
                      )
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < meses.length) {
                          return Text(meses[index].substring(5));
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CategoriesPage
class CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.edit),
        label: Text('Gestionar Categorías'),
        onPressed: () async {
          final resultado = await Navigator.push<List<Categoria>>(
            context,
            MaterialPageRoute(
              builder: (_) => CategoriaManagerPage(),
            ),
          );

          if (resultado != null) {
            final catBox = Hive.box<Categoria>('categorias');
            final nuevasCategorias = catBox.values.toList();
            Navigator.pop(context); // cerramos CategoriesPage
            // y pasamos las nuevas al HomePage
            // requiere modificación en CategoriesPage también si quieres usar callback
          }
        },
      ),
    );
  }
}

class CategoriaManagerPage extends StatefulWidget {
  @override
  State<CategoriaManagerPage> createState() => _CategoriaManagerPageState();
}

class _CategoriaManagerPageState extends State<CategoriaManagerPage> {
  final TextEditingController _nombreController = TextEditingController();
  TipoTransaccion _tipoSeleccionado = TipoTransaccion.gasto;

  @override
  Widget build(BuildContext context) {
    final categoriaBox = Hive.box<Categoria>('categorias');
    final categorias = categoriaBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text('Gestionar Categorías')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre de la categoría'),
            ),
            DropdownButton<TipoTransaccion>(
              value: _tipoSeleccionado,
              onChanged: (val) => setState(() => _tipoSeleccionado = val!),
              items: TipoTransaccion.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo == TipoTransaccion.ingreso ? 'Ingreso' : 'Gasto'),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nombreController.text.isEmpty) return;
                final nueva = Categoria(
                  id: DateTime.now().millisecondsSinceEpoch & 0xFFFFFFFF,
                  nombre: _nombreController.text,
                  tipo: _tipoSeleccionado,
                );
                categoriaBox.put(nueva.id, nueva);
                _nombreController.clear();
                setState(() {});
              },
              child: Text('Agregar Categoría'),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final c = categorias[index];
                  return ListTile(
                    title: Text(c.nombre),
                    subtitle: Text(c.tipo == TipoTransaccion.ingreso ? 'Ingreso' : 'Gasto'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        categoriaBox.delete(c.id);
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, categorias),
              child: Text('Guardar y Volver'),
            )
          ],
        ),
      ),
    );
  }
}