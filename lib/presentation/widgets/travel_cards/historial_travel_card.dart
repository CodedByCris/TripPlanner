import 'package:flutter/material.dart';

class HistorialTravelCard extends StatefulWidget {
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
  State<HistorialTravelCard> createState() => _HistorialTravelCardState();
}

class _HistorialTravelCardState extends State<HistorialTravelCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          width: double.infinity,
          child: Card(
            elevation: 5,
            margin:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flight_takeoff),
                      const SizedBox(width: 10),
                      Text(
                        ' ${widget.origen} - ${widget.destino}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.date_range),
                      const SizedBox(width: 10),
                      Text(
                        ' ${widget.fechaSalida.toString().split(' ')[0]} - ${widget.fechaLlegada.toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
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
