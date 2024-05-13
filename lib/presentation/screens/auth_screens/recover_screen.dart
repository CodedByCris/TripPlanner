import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner/presentation/functions/alerts.dart';

import '../../../conf/connectivity.dart';
import '../../Database/connections.dart';
import '../../functions/errors.dart';
import '../../widgets/widgets.dart';

class RecoverScreen extends StatefulWidget {
  const RecoverScreen({super.key});

  @override
  State<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  @override
  Widget build(BuildContext context) {
    //final textStyles = Theme.of(context).textTheme;
    return NetworkSensitive(
      child: Scaffold(
          body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Banner

            const SizedBox(height: 50),

            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
              ),
              child: const _RecoverForm(),
            )
          ],
        ),
      )),
    );
  }
}

class _RecoverForm extends ConsumerWidget {
  const _RecoverForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = TextEditingController();
    final password = TextEditingController();
    final repeatPassword = TextEditingController();
    final db = DatabaseHelper();
    final formKey = GlobalKey<FormState>(); // Agrega esta línea

    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Form(
        // Agrega esta línea
        key: formKey, // Agrega esta línea
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text('Recuperar contraseña', style: textStyles.titleLarge),
            const SizedBox(height: 50),
            CustomTextFormField(
              controller: correo,
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                // Agrega esta línea
                if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                    .hasMatch(value!)) {
                  return 'Por favor, ingrese un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            CustomTextFormField(
              label: 'Contraseña',
              obscureText: true,
              controller: password,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor ingrese una contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            CustomTextFormField(
              label: 'Repita la contraseña',
              obscureText: true,
              controller: repeatPassword,
              validator: (value) {
                if (value != password.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _btnRecuperar(correo, password, repeatPassword, db,
                  context, formKey), // Agrega este parámetro
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Iniciar sesión'))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btnRecuperar(
      TextEditingController correo,
      TextEditingController password,
      TextEditingController repeatPassword,
      DatabaseHelper db,
      BuildContext context,
      GlobalKey<FormState> formKey) {
    // Agrega este parámetro
    return CustomFilledButton(
        text: 'Recuperar contraseña',
        buttonColor: Colors.black,
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            // Agrega esta línea
            String email = correo.text;
            String pass = password.text;
            String repPass = repeatPassword.text;
            bool loginSuccessful = false;

            //* Consulta SQL
            await db.getConnection().then((conn) async {
              String sql = 'select Correo from Usuario';
              await conn.query(sql).then((result) {
                for (final row in result) {
                  //* Comprobación de que el correo existe
                  if (email == row[0]) {
                    if (pass == repPass) {
                      loginSuccessful = true;
                      break;
                    }
                  }
                  //* Comprobación de las 2 contraseñas iguales
                }
              });

              if (loginSuccessful) {
                await conn.query(
                  "UPDATE Usuario SET Password = ? WHERE Correo = ?",
                  [pass, email],
                );
                Alerts().recoverySuccessfully(context);
                context.go('/login');
              } else {
                Errors().emailDontExist(context);
              }
            });
          }
        });
  }
}
