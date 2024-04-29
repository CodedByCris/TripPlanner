import 'package:flutter/material.dart';

class HistorialTravelCard extends StatelessWidget {
  final String origen;
  final String destino;
  final DateTime fechaSalida;
  final DateTime fechaLlegada;

  const HistorialTravelCard({
    super.key,
    required this.origen,
    required this.destino,
    required this.fechaSalida,
    required this.fechaLlegada,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Card(
            elevation: 9,
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Origen: $origen',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Destino: $destino',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Fecha de salida: $fechaSalida',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Fecha de llegada: $fechaLlegada',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
