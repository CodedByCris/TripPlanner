import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../functions/snackbars.dart';

Widget ubiActual(ColorScheme colors, controller, context) {
  return IconButton(
    icon: Icon(
      Icons.location_on,
      color: colors.primary,
    ),
    onPressed: () async {
      // Solicita los permisos de ubicación
      PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        // Si los permisos son concedidos, obtén la ubicación actual del usuario
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        // Obtiene la lista de placemarks a partir de las coordenadas de la ubicación
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        // Obtiene el primer placemark de la lista
        Placemark placemark = placemarks[0];
        // Pregunta al usuario si desea asignar la ubicación actual como origen
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Asignar ubicación como origen'),
              content:
                  Text('¿Deseas asignar ${placemark.locality} como tu origen?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    // Si el usuario acepta, escribe el nombre de la ciudad en el campo de texto
                    controller.text = placemark.locality!;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (status.isPermanentlyDenied) {
        // Si los permisos son denegados permanentemente, muestra un diálogo
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Permisos de ubicación'),
              content: const Text(
                  'Por favor, habilita los permisos de ubicación desde la configuración de la aplicación.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        Snackbar().mensaje(context,
            'Por favor, concede los permisos para obtener tu ubicación');
      }
    },
  );
}
