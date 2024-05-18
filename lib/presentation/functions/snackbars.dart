import 'package:flutter/material.dart';

class Snackbar {
  mensaje(BuildContext context, String mensaje) {
    final snackbar = SnackBar(content: Text(mensaje));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
