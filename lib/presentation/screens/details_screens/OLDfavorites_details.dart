// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mysql1/mysql1.dart';
// import 'package:trip_planner/presentation/Database/connections.dart';

// import '../../functions/snackbars.dart';
// import '../../providers/token_provider.dart';

// class FavoriteDetails extends StatefulWidget {
//   final int idViaje;
//   final String correo2;

//   const FavoriteDetails(
//       {super.key, required this.idViaje, required this.correo2});

//   @override
//   State<FavoriteDetails> createState() => _FavoriteDetailsState();
// }

// class _FavoriteDetailsState extends State<FavoriteDetails> {
//   String? miCorreo;
//   DatabaseHelper bd = DatabaseHelper();
//   Results? resultViaje;
//   Results? resultRuta;
//   Results? resultGastos;
//   MySqlConnection? conn;
//   bool isFavorite = false;

//   @override
//   void initState() {
//     super.initState();
//     setupConnection().then((_) {
//       checkFavorite();
//       fetchData();
//     }); // Llama a la función fetchData
//   }

//   Future<void> setupConnection() async {
//     conn = await bd.getConnection();
//     miCorreo = await bd.getCorreo();
//   }

//   Future<void> checkFavorite() async {
//     var result = await conn!.query(
//         'SELECT * FROM Favoritos WHERE idViaje = ${widget.idViaje} AND Correo = "$miCorreo"');
//     setState(() {
//       isFavorite = result.isNotEmpty;
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   // Crea una nueva función fetchData
//   Future<void> fetchData() async {
//     resultViaje = await conn!.query(
//         'SELECT Destino, Origen, FechaSalida, FechaLlegada, NotasViaje FROM Viaje WHERE idViaje = ${widget.idViaje}');
//     resultRuta = await conn!.query(
//         'SELECT Ubicacion, NotasRuta, Orden FROM Ruta WHERE idViaje = ${widget.idViaje}');
//     resultGastos = await conn!.query(
//         'SELECT Descripción, Cantidad, FechaGasto FROM Gastos_del_Viaje WHERE idViaje = ${widget.idViaje}');
//   }

//   Future<void> addToFavorites() async {
//     await conn!.query(
//         'INSERT INTO Favoritos (Correo, IdViaje) VALUES ("${miCorreo!}", ${widget.idViaje})');
//     setState(() {
//       isFavorite = true;
//     });
//     Snackbar().mensaje(context, 'Viaje agregado a favoritos');
//   }

//   Future<void> removeFromFavorites() async {
//     await conn!.query(
//         'DELETE FROM Favoritos WHERE Correo = "${miCorreo!}" AND IdViaje = ${widget.idViaje}');
//     setState(() {
//       isFavorite = false;
//     });
//     Snackbar().mensaje(context, 'Viaje eliminado de favoritos');
//   }

//   @override
//   Widget build(BuildContext context) {
//     //print('FAVORITOS_DETAILS');
//     return Consumer(builder: (context, ref, child) {
//       return FutureBuilder(
//         future: setupConnection().then((_) => fetchData()),
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Scaffold(
//               appBar: AppBar(
//                 centerTitle: true,
//                 title: const Text(
//                   'DETALLES DEL VIAJE',
//                   style: TextStyle(fontSize: 20),
//                 ),
//               ),
//               body: const Center(child: CircularProgressIndicator()),
//             );
//           } else {
//             return Scaffold(
//               appBar: AppBar(
//                 centerTitle: true,
//                 title: const Text(
//                   'DETALLES DEL VIAJE',
//                   style: TextStyle(fontSize: 20),
//                 ),
//                 actions: <Widget>[
//                   if (miCorreo != null)
//                     IconButton(
//                       icon: Icon(
//                           isFavorite ? Icons.favorite : Icons.favorite_border),
//                       onPressed: () {
//                         if (isFavorite) {
//                           removeFromFavorites();
//                         } else {
//                           addToFavorites();
//                         }
//                         ref.read(favoriteTripsProvider.notifier).refresh();
//                       },
//                     ),
//                 ],
//               ),
//               body: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ListView(
//                   children: [
//                     const SizedBox(height: 20),
//                     const Text('Datos del viaje:',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 10),
//                     viaje(resultViaje),
//                     const Divider(height: 40),
//                     const Text('Rutas:',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 10),
//                     rutas(resultRuta),
//                     const Divider(height: 40),
//                     const Text('Gastos:',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 10),
//                     gastos(resultGastos),
//                   ],
//                 ),
//               ),
//             );
//           }
//         },
//       );
//     });
//   }

//   Widget viaje(resultViaje) {
//     if (resultViaje == null || resultViaje!.isEmpty) {
//       return const Text('No hay datos del viaje');
//     } else {
//       List<ResultRow> rows = resultViaje!.toList();
//       return ListView.builder(
//         shrinkWrap: true,
//         itemCount: rows.length,
//         itemBuilder: (context, index) {
//           ResultRow row = rows[index];
//           return GestureDetector(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: ListTile(
//                     leading: const Icon(Icons.flight,
//                         size: 40.0), // Add your icon here
//                     title: Text(
//                       '${row['Origen']} - ${row['Destino']}',
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 19),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 20),
//                         Text(
//                           '${row['FechaSalida'].toIso8601String().substring(0, 10)} - ${row['FechaLlegada'].toIso8601String().substring(0, 10)}',
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           '${row['NotasViaje']}',
//                           style:
//                               const TextStyle(fontSize: 14, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }
//   }

// // Crea un widget llamado rutas
//   Widget rutas(resultRuta) {
//     if (resultRuta == null || resultRuta!.isEmpty) {
//       return const Text('No hay datos de las rutas');
//     } else {
//       List<ResultRow> rows = resultRuta!.toList();
//       return ConstrainedBox(
//         constraints: const BoxConstraints(maxHeight: 300),
//         child: ListView.builder(
//           shrinkWrap: true,
//           itemCount: rows.length,
//           itemBuilder: (context, index) {
//             ResultRow row = rows[index];
//             return GestureDetector(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: ListTile(
//                       leading: const Icon(Icons.map, size: 40.0),
//                       title: Text(
//                         '${row['Ubicacion']}',
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 19),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 20),
//                           Text(
//                             '  ${row['NotasRuta']}',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     }
//   }

// // Crea un widget llamado gastos
//   Widget gastos(resultGastos) {
//     if (resultGastos == null || resultGastos!.isEmpty) {
//       return const Text('No hay datos de los gastos');
//     } else {
//       List<ResultRow> rows = resultGastos!.toList();
//       return ConstrainedBox(
//         constraints: const BoxConstraints(maxHeight: 300),
//         child: ListView.builder(
//           shrinkWrap: true,
//           itemCount: rows.length,
//           itemBuilder: (context, index) {
//             ResultRow row = rows[index];
//             return GestureDetector(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: ListTile(
//                       leading: const Icon(Icons.money,
//                           size: 40.0), // Add your icon here
//                       title: Text(
//                         ' ${row['Cantidad']}',
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 19),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 20),
//                           Text(
//                             '  ${row['Descripción']}',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                           const SizedBox(height: 20),
//                           Text(
//                             'Fecha: ${row['FechaGasto'].toIso8601String().substring(0, 10)}',
//                             style: const TextStyle(
//                                 fontSize: 14, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     }
//   }
// }
