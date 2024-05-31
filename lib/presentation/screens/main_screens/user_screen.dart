// ignore_for_file: unused_catch_clause, use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../Database/connections.dart';
import '../../functions/snackbars.dart';
import '../../providers/theme_provider.dart';
import '../../providers/token_provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  UserScreenState createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef ref, child) {
        final colors = Theme.of(context).colorScheme;
        final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
        final nombre = ref.watch(userNameProvider); // Mover aquí
        final correo = ref.watch(tokenProvider); // Mover aquí
        final imagen = ref.watch(imageProvider); // Mover aquí
        final viajesFavoritos =
            correo != null ? ref.watch(favoriteTripsProvider) : 0;
        final viajesCompletados =
            correo != null ? ref.watch(completedTripsProvider) : 0;

        return Scaffold(
          appBar: _customAppBar(isDarkMode, ref, colors, correo, context),
          //*Cuerpo de la aplicación
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: _userView(
                ref,
                context,
                nombre,
                correo,
                imagen,
                isDarkMode,
                viajesFavoritos,
                viajesCompletados), // Asegúrate de actualizar _userView para usar imageUrl en lugar de ref.watch(imageProvider)
          ),
        );
      },
    );
  }

  AppBar _customAppBar(bool isDarkMode, WidgetRef ref, ColorScheme colors,
      String? correo, BuildContext context) {
    return AppBar(
      title: Text(
        "PERFIL DE USUARIO",
        style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black, fontSize: 20),
      ),
      centerTitle: true,
      // Modo nocturno
      leading: IconButton(
        onPressed: () {
          ref.read(themeNotifierProvider.notifier).toggleDarkMode();
        },
        icon: Icon(
            isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
        color: colors.primary,
      ),

      // Icono para las conversaciones
      actions: correo != null
          ? [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Cerrar sesión'),
                        content: const Text(
                            '¿Estás seguro de que quieres cerrar sesión?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Aceptar'),
                            onPressed: () async {
                              // Delete the token
                              await ref
                                  .read(tokenProvider.notifier)
                                  .deleteToken();
                              Snackbar().mensaje(context,
                                  'Sesión cerrada... Volviendo al login');
                              // Redirect the user to the login screen
                              Navigator.of(context).pop();
                              GoRouter.of(context).go('/login');
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout_outlined),
                color: Colors.red,
              )
            ]
          : [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Iniciar Sesión'),
                        content: const Text(
                            '¿Estás seguro de que quieres iniciar sesión?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Aceptar'),
                            onPressed: () async {
                              // Redirect the user to the login screen
                              Navigator.of(context).pop();
                              GoRouter.of(context).go('/login');
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.login_outlined),
                color: Colors.blue,
              )
            ],
    );
  }

  Widget _userView(WidgetRef ref, BuildContext context, nombre, correo, imagen,
      isDarkMode, viajesFav, viajesComp) {
    final List<Color> colors = ref.watch(colorListProvider);
    final int selectedColor = ref.watch(themeNotifierProvider).selectedColor;

    return Column(
      children: [
        const SizedBox(height: 30),
        //* Foto del usuario
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            correo != null
                ? _imagen(imagen, colors, selectedColor)
                : Icon(Icons.person, size: 100, color: colors[selectedColor]),
            correo != null
                ? _logoCamara(ref, correo, context)
                : const SizedBox(),
          ],
        ),
        const SizedBox(height: 20),

        Text(correo != null ? nombre : 'Invitado',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            )),

        const SizedBox(height: 5),

        Text(correo ?? 'invitado@gmail.com',
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode
                  ? const Color.fromARGB(255, 169, 169, 169)
                  : const Color.fromARGB(255, 84, 84, 84),
            )),

        const SizedBox(height: 20),
        _numViajes(isDarkMode, viajesFav, viajesComp),
        const SizedBox(height: 20),
        const SizedBox(height: 10),
        SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView(
              children: [
                _colores(colors, selectedColor, ref),
                _informacion(colors, selectedColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _numViajes(isDarkMode, viajesFav, viajesComp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 5), // Reduced padding
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[850]
                    : Colors.white, // Color depends on isDarkMode
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3, // Reduced spreadRadius
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text("Viajes favoritos",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? const Color.fromARGB(255, 169, 169, 169)
                            : const Color.fromARGB(255, 84, 84, 84),
                      )),
                  Text(
                    viajesFav.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10), // Changed from height to width
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 5), // Reduced padding
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[850]
                    : Colors.white, // Color depends on isDarkMode
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3, // Reduced spreadRadius
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text("Viajes totales",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? const Color.fromARGB(255, 169, 169, 169)
                            : const Color.fromARGB(255, 84, 84, 84),
                      )),
                  Text(
                    viajesComp.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagen(String? imagen, List<Color> colors, int selectedColor) {
    return FutureBuilder<String>(
      future: Future.value(imagen ?? ''), // convert String? to Future<String>
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        Widget widget;
        if (snapshot.connectionState == ConnectionState.waiting) {
          widget =
              const CircularProgressIndicator(); // show loading spinner while waiting for image to load
        } else if (snapshot.hasError) {
          widget = const Icon(Icons
              .error); // show error icon if there was an error loading the image
        } else {
          if (snapshot.data != "") {
            //print('Image URL: ${snapshot.data}'); // print the image URL
            widget = Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: colors[selectedColor],
                    width: 3.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(22), // Adjust the radius as needed
                  child: snapshot.data!.contains('http')
                      ? CachedNetworkImage(
                          imageUrl: snapshot.data!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Image(
                          image: FileImage(File(snapshot.data!)),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                ));
          } else {
            widget =
                Icon(Icons.person, size: 100, color: colors[selectedColor]);
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

  Future<void> updateImage(String email, String imageUrl, context, ref) async {
    DatabaseHelper db = DatabaseHelper();

    await db.getConnection().then((conn) async {
      await conn.query(
        "UPDATE Usuario SET Imagen = ? WHERE Correo = ?",
        [imageUrl, email],
      );

      Snackbar().mensaje(context, 'Foto de perfil actualizada correctamente');
      this.imageUrl = imageUrl;
      ref.read(imageProvider.notifier).refresh();
    });
  }

  Future<String> subirImagen(String rutaImagen) async {
    try {
      //Crea una referencia a la ubicación a la que quieres subir en Firebase Storage
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref('/$rutaImagen');

      // Sube el archivo a Firebase Storage
      firebase_storage.UploadTask tareaSubida = ref.putFile(File(rutaImagen));

      // Espera hasta que el archivo se haya subido
      await tareaSubida.whenComplete(() => null);

      // Obtiene la URL del archivo subido
      String urlDescarga = await ref.getDownloadURL();

      return urlDescarga;
    } on firebase_storage.FirebaseException catch (e) {
      // Maneja cualquier error
      //print(e);
      return '';
    }
  }

  Widget _logoCamara(WidgetRef ref, String correo, context) {
    return PopupMenuButton<ImageSource>(
      icon: const Icon(
        Icons.camera_alt,
        color: Colors.white,
        size: 35,
      ),
      onSelected: (ImageSource source) async {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: source);
        if (pickedFile != null) {
          String rutaImagen = pickedFile.path;

          // Sube la imagen y obtén la URL
          String urlImagen = await subirImagen(rutaImagen);

          // Obtiene el correo electrónico del usuario
          final correo = ref.watch(tokenProvider);

          // Actualiza la imagen en la base de datos
          updateImage(correo!, urlImagen, context, ref);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ImageSource>>[
        const PopupMenuItem<ImageSource>(
          value: ImageSource.camera,
          child: ListTile(
            leading: Icon(Icons.camera),
            title: Text('Camera'),
          ),
        ),
        const PopupMenuItem<ImageSource>(
          value: ImageSource.gallery,
          child: ListTile(
            leading: Icon(Icons.photo_album),
            title: Text('Gallery'),
          ),
        ),
      ],
    );
  }

  Widget _informacion(List<Color> colors, int selectedColor) {
    return ListTile(
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INFORMACIÓN',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Esta aplicación fue desarrollada por Cristian Arellano para el proyecto final del grado superior de Desarrollo de Aplicaciones Multiplataforma en el I.E.S. Florencio Pintado.',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Versión 1.4',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
      leading: Icon(
        Icons.info,
        color: colors[selectedColor],
        size: 30,
      ),
      title: const Text(
        "Información de la app",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Text("Version 1.4",
          style: TextStyle(
            fontSize: 15,
          )),
    );
  }

  Widget _colores(List<Color> colors, int selectedColor, WidgetRef ref) {
    return ExpansionTile(
      leading: Icon(
        Icons.format_paint_sharp,
        color: colors[selectedColor],
        size: 30,
      ),
      title: const Text(
        "Apariencia de la app",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [
        SizedBox(
          height: 230,
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final color = colors[index];
              return RadioListTile(
                  subtitle: const Text('Click para cambiar'),
                  title: Text(
                    "Cambiar color",
                    style: TextStyle(color: color),
                  ),
                  activeColor: color,
                  value: index,
                  groupValue: selectedColor,
                  onChanged: (value) {
                    ref
                        .read(themeNotifierProvider.notifier)
                        .changeColorIndex(index);
                  });
            },
            itemCount: colors.length,
          ),
        ),
      ],
    );
  }
}
