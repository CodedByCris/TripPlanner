import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

Widget viaje(resultViaje) {
  if (resultViaje == null || resultViaje!.isEmpty) {
    return const Text('No hay datos del viaje');
  } else {
    List<ResultRow> rows = resultViaje!.toList();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: rows.length,
      itemBuilder: (context, index) {
        ResultRow row = rows[index];
        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('¿Qué quieres hacer?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Modificar'),
                      onPressed: () {
                        // Aquí va el código para modificar el viaje
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row['Origen']} - ${row['Destino']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 19),
                ),
                const SizedBox(height: 10),
                Text(
                  '${row['FechaSalida'].toIso8601String().substring(0, 10)} - ${row['FechaLlegada'].toIso8601String().substring(0, 10)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  '${row['NotasViaje']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Crea un widget llamado rutas
Widget rutas(resultRuta) {
  if (resultRuta == null || resultRuta!.isEmpty) {
    return const Text('No hay datos de las rutas');
  } else {
    List<ResultRow> rows = resultRuta!.toList();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: rows.length,
      itemBuilder: (context, index) {
        ResultRow row = rows[index];
        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return _dialog(context);
              },
            );
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row['Ubicacion']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 19),
                ),
                const SizedBox(height: 10),
                Text(
                  'Notas: ${row['NotasRuta']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Crea un widget llamado gastos
Widget gastos(resultGastos) {
  if (resultGastos == null || resultGastos!.isEmpty) {
    return const Text('No hay datos de los gastos');
  } else {
    List<ResultRow> rows = resultGastos!.toList();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: rows.length,
      itemBuilder: (context, index) {
        ResultRow row = rows[index];
        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return _dialog(context);
              },
            );
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row['Concepto']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 19),
                ),
                const SizedBox(height: 10),
                Text(
                  'Importe: ${row['Importe']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Fecha: ${row['Fecha']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Notas: ${row['NotasGasto']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _dialog(BuildContext context) {
  return AlertDialog(
    title: const Text('¿Qué quieres hacer?'),
    actions: <Widget>[
      TextButton(
        child: const Text('Cancelar'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: const Text('Modificar'),
        onPressed: () {
          // Aquí va el código para modificar la ruta
        },
      ),
      TextButton(
        child: const Text('Eliminar'),
        onPressed: () {
          // Aquí va el código para eliminar la ruta
        },
      ),
    ],
  );
}
