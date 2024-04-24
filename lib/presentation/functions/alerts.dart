import 'package:flutter/material.dart';

class Alerts {
  registerSuccessfully(BuildContext context) {
    const snackbar = SnackBar(
        content: Text('Cuenta creada correctamente... Iniciando sesión'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  loginSuccessfully(BuildContext context) {
    const snackbar = SnackBar(content: Text('Iniciando sesión...'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  recoverySuccessfully(BuildContext context) {
    const snackbar =
        SnackBar(content: Text('Contraseña cambiada correctamente'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
