import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Snackbar {
  mensaje(context, String mensaje) {
    Fluttertoast.showToast(
        msg: mensaje,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // Use `ToastGravity.TOP` for top position
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
