import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/Database/connections.dart';

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
        return Card(
          elevation: 3,
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row['Origen']} - ${row['Destino']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
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
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('${row['Ubicacion']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Text('Notas: ${row['NotasRuta']}'),
            ],
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
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Text(
                '${row['Descripción']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              const SizedBox(height: 10),
              Text('Cantidad: ${row['Cantidad']}'),
              row['FechaGasto'] == null
                  ? const Text('Fecha: No hay fecha')
                  : Text('Fecha: ${row['FechaGasto']}'),
            ],
          ),
        );
      },
    );
  }
}
