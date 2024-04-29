import 'package:flutter/material.dart';

class ActualTravelCard extends StatelessWidget {
  final String origen;
  final String destino;
  final DateTime fechaSalida;
  final DateTime fechaLlegada;

  const ActualTravelCard({
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
        const Text(
          'Pulsa para modificar los datos del viaje',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 9, 61, 104),
          ),
        ),
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
