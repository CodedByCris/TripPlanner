// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mysql1/mysql1.dart';
// import 'package:trip_planner/presentation/screens/screens.dart';

// import '../../Database/connections.dart';
// import '../../providers/theme_provider.dart';
// import 'add_group_screen.dart';
// import 'chat_screen.dart';

// bool hayDatosss = false;

// class MessagesScreen extends StatefulWidget {
//   const MessagesScreen({super.key});

//   @override
//   State<MessagesScreen> createState() => _MessagesScreenState();
// }

// class _MessagesScreenState extends State<MessagesScreen> {
//   final db = DatabaseHelper();
//   Map<String, List<ResultRow>> groupedData = {};
//   bool isLoading = false;
//   MySqlConnection? conn;
//   bool? esgrupo;

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     groupedData.clear();

//     setState(() {
//       isLoading = true; // Set isLoading to true before loading the data
//     });
//     conn = await db.getConnection();

//     // Query the Usuario_GrupoViaje table
//     final result = await conn!.query(
//         'SELECT IdGrupo FROM Usuario_GrupoViaje WHERE Correo = ?', [correo]);

//     if (result.isEmpty) {
//       setState(() {
//         hayDatosss = false;
//       });
//     } else {
//       setState(() {
//         hayDatosss = true;
//       });

//       // Perform a second query to the Grupos_de_Viaje table
//       for (var row in result) {
//         final grupoResult = await conn!.query(
//             'SELECT Descripción, FechaCreacion, NombreGrupo, TipoGrupo FROM Grupos_de_Viaje WHERE IdGrupo = ?',
//             [row['IdGrupo']]);

//         // If there is no NombreGrupo or Descripción, it's a private chat
//         if (grupoResult.first['NombreGrupo'] == "" &&
//             grupoResult.first['Descripción'] == "") {
//           // Query the Usuario_GrupoViaje table to get the Correo of the other user in the group
//           final otherUserResult = await conn!.query(
//               'SELECT Correo FROM Usuario_GrupoViaje WHERE IdGrupo = ? AND Correo != ?',
//               [row['IdGrupo'], correo]);

//           // Query the Usuario table to get the NombreUsuario and Imagen of the other user
//           final usuarioResult = await conn!.query(
//               'SELECT NombreUsuario, Imagen FROM Usuario WHERE Correo = ?',
//               [otherUserResult.first['Correo']]);

//           // Add the results to the groupedData map
//           groupedData[row['IdGrupo'].toString()] = usuarioResult.toList();
//         } else {
//           // Add the results of the Grupos_de_Viaje query to the groupedData map
//           groupedData[row['IdGrupo'].toString()] = grupoResult.toList();
//         }
//       }
//     }

//     setState(() {
//       isLoading = false; // Set isLoading to false after loading the data
//     });
//   }

//   Future<void> deleteData(String key) async {
//     // Delete from Usuario_GrupoViaje
//     await conn!.query(
//       'DELETE FROM Usuario_GrupoViaje WHERE IdGrupo = ?',
//       [key],
//     );
//     // Delete from Grupos_de_Viaje
//     await conn!.query(
//       'DELETE FROM Grupos_de_Viaje WHERE IdGrupo = ?',
//       [key],
//     );
//     await fetchData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     //print("Resultados $groupedData");
//     return Consumer(
//       builder: (context, ref, child) {
//         final colors = Theme.of(context).colorScheme;
//         final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

//         return Scaffold(
//           appBar: AppBar(
//             centerTitle: true,
//             title: Text(
//               'MENSAJES',
//               style: TextStyle(
//                 color: isDarkMode
//                     ? colors.secondary
//                     : const Color.fromARGB(255, 9, 61, 104),
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.add),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const AddGroupScreen(),
//                     ),
//                   ).then((_) {
//                     setState(() {
//                       fetchData();
//                     });
//                   });
//                 },
//               ),
//             ],
//           ),
//           body: hayDatosss
//               ? ListView.separated(
//                   itemCount: groupedData.length,
//                   separatorBuilder: (context, index) =>
//                       const SizedBox(height: 10), // Define your separator here
//                   itemBuilder: (context, index) {
//                     String key = groupedData.keys.elementAt(index);
//                     var data = groupedData[key]![0];
//                     String imageUrl = data.fields['Imagen'].toString();
//                     Widget leadingWidget;

//                     if (imageUrl.isEmpty || imageUrl.compareTo("null") == 0) {
//                       leadingWidget = const Icon(Icons.group);
//                     } else {
//                       leadingWidget = Image.network(imageUrl);
//                     }

//                     if (data.fields['NombreUsuario'] != null) {
//                       //print("key-> $key");
//                       // It's a private chat, display the NombreUsuario and leadingWidget
//                       return ListTile(
//                         onTap: () {
//                           esgrupo = false;
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ChatBDScreen(
//                                   esgrupo: esgrupo!,
//                                   imagen: imageUrl,
//                                   nombre:
//                                       data.fields['NombreUsuario'].toString(),
//                                   correo: correo!,
//                                   idGrupo:
//                                       key), // Pass the idGrupo to ChatScreen
//                             ),
//                           );
//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             setState(() {
//                               fetchData();
//                             });
//                           });
//                         },
//                         onLongPress: () async {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Text('Eliminar conversación'),
//                                 content: const Text(
//                                     '¿Estás seguro de que quieres eliminar esta conversación?'),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     child: const Text('Cancelar'),
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                   ),
//                                   TextButton(
//                                     child: const Text('Eliminar'),
//                                     onPressed: () async {
//                                       await deleteData(key);
//                                       Navigator.of(context).pop();
//                                       WidgetsBinding.instance
//                                           .addPostFrameCallback((_) {
//                                         setState(() {
//                                           fetchData();
//                                         });
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                         leading:
//                             imageUrl.isEmpty || imageUrl.compareTo("null") == 0
//                                 ? CircleAvatar(
//                                     radius: 50,
//                                     backgroundColor: Colors
//                                         .transparent, // Adjust the size of the image
//                                     child: leadingWidget,
//                                   )
//                                 : CircleAvatar(
//                                     radius: 50, // Adjust the size of the image
//                                     backgroundImage: NetworkImage(imageUrl),
//                                     backgroundColor: Colors.transparent,
//                                   ),
//                         title: Text(
//                           data.fields['NombreUsuario'].toString(),
//                           style: const TextStyle(
//                             fontSize: 20, // Adjust the size of the title
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       );
//                     } else {
//                       // It's a group chat, display the NombreGrupo and Descripción
//                       return ListTile(
//                         onTap: () {
//                           esgrupo = true;
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ChatBDScreen(
//                                   esgrupo: esgrupo!,
//                                   imagen: imageUrl,
//                                   nombre: data.fields['NombreGrupo'].toString(),
//                                   correo: correo!,
//                                   idGrupo:
//                                       key), // Pass the idGrupo to ChatScreen
//                             ),
//                           );
//                         },
//                         onLongPress: () async {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const Text('Eliminar grupo'),
//                                 content: const Text(
//                                     '¿Estás seguro de que quieres eliminar este grupo?'),
//                                 actions: <Widget>[
//                                   TextButton(
//                                     child: const Text('Cancelar'),
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                   ),
//                                   TextButton(
//                                     child: const Text('Eliminar'),
//                                     onPressed: () async {
//                                       Navigator.of(context).pop();
//                                       await deleteData(key);
//                                     },
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                         leading:
//                             imageUrl.isEmpty || imageUrl.compareTo("null") == 0
//                                 ? CircleAvatar(
//                                     radius: 50,
//                                     backgroundColor: Colors
//                                         .transparent, // Adjust the size of the image
//                                     child: leadingWidget,
//                                   // )
//                                 : CircleAvatar(
//                                     radius: 50, // Adjust the size of the image
//                                     backgroundImage: NetworkImage(imageUrl),
//                                     backgroundColor: Colors.transparent,
//                                   ),
//                         title: Text(data.fields['NombreGrupo']
//                             .toString()), // Display the group's name
//                         subtitle: Text(data.fields['Descripción']
//                             .toString()), // Display the group's description
//                       );
//                     }
//                   },
//                 )
//               : Center(
//                   child: Text(
//                     'No tienes conversaciones activas',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: isDarkMode
//                           ? colors.secondary
//                           : const Color.fromARGB(255, 9, 61, 104),
//                     ),
//                   ),
//                 ),
//         );
//       },
//     );
//   }
// }
