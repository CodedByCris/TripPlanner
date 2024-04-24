import 'package:flutter/material.dart';

class Errors {
  isEmpty(BuildContext context) {
    const snackbar = SnackBar(content: Text('No puedes dejar el campo vacío'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  oneCharacter(BuildContext context) {
    const snackbar = SnackBar(content: Text('Debes escribir más de una letra'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  userDontExist(BuildContext context) {
    const snackbar = SnackBar(content: Text('El usuario no existe'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  emailDontExist(BuildContext context) {
    const snackbar =
        SnackBar(content: Text('El email no existe, prueba con otra'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  emailExist(BuildContext context) {
    const snackbar = SnackBar(
      content: Text('La cuenta de email ya existe'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  passwordNotEquals(BuildContext context) {
    const snackbar = SnackBar(content: Text('Las contraseñas no son iguales'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
