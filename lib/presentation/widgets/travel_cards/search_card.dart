import 'package:flutter/material.dart';

import '../../Database/connections.dart';

class SearchCard extends StatefulWidget {
  final String origen;
  final String destino;
  final DateTime fechaSalida;
  final DateTime fechaLlegada;
  final double gastos;
  final int numRutas;
  final String correoUsuario;
  final Map<String, dynamic> userData;

  const SearchCard({
    super.key,
    required this.origen,
    required this.destino,
    required this.fechaSalida,
    required this.fechaLlegada,
    required this.gastos,
    required this.numRutas,
    required this.correoUsuario,
    required this.userData,
  });

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  String nombreUsuario = '';
  String imagenUsuario = '';

  @override
  void initState() {
    super.initState();
    fetchUsuarioData();
    nombreUsuario = widget.userData['NombreUsuario'] ?? "";
    imagenUsuario = widget.userData['Imagen'] ?? "";
  }

  Future<void> fetchUsuarioData() async {
    final db = DatabaseHelper();
    var conn = await db.getConnection();
    final result = await conn.query(
        'SELECT NombreUsuario, Imagen FROM Usuario WHERE Correo = ?',
        [widget.correoUsuario]);

    if (result.isNotEmpty) {
      setState(() {
        nombreUsuario = result.first['NombreUsuario'] ?? "";
        imagenUsuario = result.first['Imagen'] ?? const Icon(Icons.person);
        //print(nombreUsuario);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          width: double.infinity,
          child: Card(
            elevation: 3,
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
                          Text(
                            '${widget.origen} - ${widget.destino}',
                            style: const TextStyle(
                              fontSize: 14,
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
                  const Divider(height: 20),
                  Row(
                    children: [
                      _imagen(),
                      const SizedBox(width: 20),
                      Text(
                        nombreUsuario != '' ? nombreUsuario : 'Usuario anónimo',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagen() {
    return FutureBuilder<String>(
      future: Future.value(imagenUsuario),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        Widget widget;
        if (snapshot.connectionState == ConnectionState.waiting) {
          widget = const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          widget = const Icon(Icons.error);
        } else {
          if (snapshot.data != "") {
            widget = Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue, // replace with your color
                  width: 3.0,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  snapshot.data!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            widget = const Icon(Icons.person);
          }
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            widget,
          ],
        );
      },
    );
  }
}
