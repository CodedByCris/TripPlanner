import 'package:flutter/material.dart';

class ActualTravelCard extends StatefulWidget {
  final String origen;
  final String destino;
  final DateTime fechaSalida;
  final DateTime fechaLlegada;
  final double gastos;
  final int numRutas;

  const ActualTravelCard({
    super.key,
    required this.origen,
    required this.destino,
    required this.fechaSalida,
    required this.fechaLlegada,
    required this.gastos,
    required this.numRutas,
  });

  @override
  State<ActualTravelCard> createState() => _ActualTravelCardState();
}

class _ActualTravelCardState extends State<ActualTravelCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Card(
            elevation: 9,
            margin:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //! ORIGEN Y DESTINO
                      Row(
                        children: [
                          const Icon(Icons.flight_takeoff),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.4, // Define your desired width here
                            child: Text(
                              '${widget.origen} - ${widget.destino}',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      //! NUMERO DE RUTAS
                      Row(
                        children: [
                          const Icon(Icons.route_outlined),
                          const SizedBox(width: 10),
                          Text(
                            "${widget.numRutas.toString()} Rutas",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //! FECHAS
                      Row(
                        children: [
                          const Icon(Icons.date_range),
                          const SizedBox(width: 10),
                          Text(
                            '${widget.fechaSalida.toString().split(' ')[0]} - ${widget.fechaLlegada.toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      //!GASTOS
                      Row(
                        children: [
                          const Icon(Icons.monetization_on),
                          const SizedBox(width: 10),
                          Text(
                            "${widget.gastos.toString()} €",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
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
