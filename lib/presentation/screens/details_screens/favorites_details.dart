import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/Database/connections.dart';

import 'detalles.dart';

class FavoriteDetails extends StatefulWidget {
  final int idViaje;
  final String correo;

  const FavoriteDetails(
      {super.key, required this.idViaje, required this.correo});

  @override
  State<FavoriteDetails> createState() => _FavoriteDetailsState();
}

class _FavoriteDetailsState extends State<FavoriteDetails> {
  String? miCorreo;
  Mysql bd = Mysql();
  Results? resultViaje;
  Results? resultRuta;
  Results? resultGastos;
  MySqlConnection? conn;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    setupConnection().then((_) {
      fetchData();
      checkFavorite();
    }); // Llama a la función fetchData
  }

  Future<void> setupConnection() async {
    conn = await bd.getConnection();
    miCorreo = await bd.getCorreo();
  }

  Future<void> checkFavorite() async {
    var result = await conn!.query(
        'SELECT * FROM Favoritos WHERE idViaje = ${widget.idViaje} AND Correo = "${widget.correo}"');
    setState(() {
      isFavorite = result.isNotEmpty;
    });
  }

  @override
  void dispose() {
    bd.closeConnection(conn!);
    super.dispose();
  }

  // Crea una nueva función fetchData
  Future<void> fetchData() async {
    resultViaje = await conn!.query(
        'SELECT Destino, Origen, FechaSalida, FechaLlegada, NotasViaje FROM Viaje WHERE idViaje = ${widget.idViaje}');
    resultRuta = await conn!.query(
        'SELECT Ubicacion, NotasRuta, Orden FROM Ruta WHERE idViaje = ${widget.idViaje}');
    resultGastos = await conn!.query(
        'SELECT Descripción, Cantidad, FechaGasto FROM Gastos_del_Viaje WHERE idViaje = ${widget.idViaje}');
  }

  Future<void> addToFavorites() async {
    await conn!.query(
        'INSERT INTO Favoritos (Correo, IdViaje) VALUES ("${miCorreo!}", ${widget.idViaje})');
    setState(() {
      isFavorite = true;
    });
  }

  Future<void> removeFromFavorites() async {
    await conn!.query(
        'DELETE FROM Favoritos WHERE Correo = "${miCorreo!}" AND IdViaje = ${widget.idViaje}');
    setState(() {
      isFavorite = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setupConnection().then((_) => fetchData()),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('DETALLES DEL VIAJE'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('DETALLES DEL VIAJE'),
              actions: <Widget>[
                IconButton(
                  icon:
                      Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  onPressed: () {
                    if (isFavorite) {
                      removeFromFavorites();
                    } else {
                      addToFavorites();
                    }
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  const Text('Datos del viaje:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  viaje(resultViaje),
                  const Divider(height: 40),
                  const Text('Rutas:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  rutas(resultRuta),
                  const Divider(height: 40),
                  const Text('Gastos:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  gastos(resultGastos),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
