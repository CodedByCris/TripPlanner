import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../Database/connections.dart';
import '../../functions/snackbars.dart';
import '../../providers/theme_provider.dart';
import '../../video/videoplayer.dart';
import '../../widgets/interface/custom_app_bar.dart';
import '../../providers/token_provider.dart';

class UserScreen extends ConsumerWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: CustomAppBar(
          isDarkMode: isDarkMode,
          colors: colors,
          titulo: 'PERFIL DE USUARIO',
        ),
      ),
      //*Cuerpo de la aplicación
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: _userView(ref, context),
      ),
    );
  }

  Widget _userView(WidgetRef ref, BuildContext context) {
    final List<Color> colors = ref.watch(colorListProvider);
    final int selectedColor = ref.watch(themeNotifierProvider).selectedColor;
    final correo = ref.watch(tokenProvider);
    final nombre = ref.watch(userNameProvider);
    final imagen = ref.watch(imageProvider);

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
        correo != null
            ? _logOutButton(context, ref)
            : _loginButton(context, ref, colors, selectedColor),

        const SizedBox(height: 10),
        SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView(
              children: [
                correo != null && nombre != null
                    ? _nombre(colors, selectedColor, nombre)
                    : _nombre(colors, selectedColor, "INVITADO"),
                correo != null
                    ? _correo(colors, selectedColor, correo)
                    : _correo(colors, selectedColor, "INVITADO@gmail.com"),
                _colores(colors, selectedColor, ref),
                _tutorial(colors, selectedColor, context),
                _informacion(colors, selectedColor),
              ],
            ),
          ),
        ),
      ],
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
            print('Image URL: ${snapshot.data}'); // print the image URL
            widget = Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors[selectedColor],
                  width: 3.0,
                ),
              ),
              child: ClipOval(
                child: snapshot.data!.contains('http')
                    ? Image.network(
                        snapshot.data!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Image(
                        image: FileImage(File(snapshot.data!)),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
              ),
            );
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

  Future<void> updateImage(String email, String imageUrl, context) async {
    DatabaseHelper db = DatabaseHelper();

    await db.getConnection().then((conn) async {
      await conn.query(
        "UPDATE Usuario SET Imagen = ? WHERE Correo = ?",
        [imageUrl, email],
      );
      Snackbar().mensaje(context, 'Foto de perfil actualizada correctamente');
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
      print(e);
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
          updateImage(correo!, urlImagen, context);
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
      leading: Icon(
        Icons.info,
        color: colors[selectedColor],
        size: 30,
      ),
      title: const Text(
        "Información de la app",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text("Version 1.0",
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
        "Apariencia de la aplicación",
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

  Widget _correo(List<Color> colors, int selectedColor, String correo) {
    return ListTile(
      leading: Icon(
        Icons.email,
        color: colors[selectedColor],
        size: 30,
      ),
      title: const Text(
        "Correo electrónico",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(correo,
          style: const TextStyle(
            fontSize: 15,
          )),
    );
  }

  Widget _nombre(List<Color> colors, int selectedColor, String nombre) {
    return ListTile(
      //TODO: Hacer una consulta a la base de datos para obtener el nombre del usuario con el correo
      leading: Icon(
        Icons.person,
        color: colors[selectedColor],
        size: 30,
      ),
      title: const Text(
        "Nombre de usuario",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        nombre,
        style: const TextStyle(
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _logOutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 200, // Set the width to your desired value
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Cerrar sesión'),
                content:
                    const Text('¿Estás seguro de que quieres cerrar sesión?'),
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
                      await ref.read(tokenProvider.notifier).deleteToken();
                      Snackbar().mensaje(
                          context, 'Sesión cerrada... Volviendo al login');
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
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10), // Reduced padding
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
        child: const Text(
          "Cerrar sesión",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context, WidgetRef ref, List<Color> colors,
      int selectedColor) {
    return SizedBox(
      width: 200, // Set the width to your desired value
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Iniciar Sesión'),
                content:
                    const Text('¿Estás seguro de que quieres iniciar sesión?'),
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
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(colors[selectedColor]),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10), // Reduced padding
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
        child: const Text(
          "Iniciar sesión",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _tutorial(
      List<Color> colors, int selectedColor, BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.question_mark,
        color: colors[selectedColor],
        size: 30,
      ),
      title: const Text(
        "¿Cómo funciona la app?",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: const Text("Ver tutorial",
          style: TextStyle(
            fontSize: 15,
          )),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VideoPlayerScreen()),
        );
      },
    );
  }
}
