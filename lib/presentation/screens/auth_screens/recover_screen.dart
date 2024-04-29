import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner/presentation/functions/alerts.dart';

import '../../../conf/connectivity.dart';
import '../../functions/connections.dart';
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

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = TextEditingController();
    final password = TextEditingController();
    final repeatPassword = TextEditingController();
    final db = Mysql();

    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Text('Recuperar contraseña', style: textStyles.titleLarge),
          const SizedBox(height: 50),
          CustomTextFormField(
            controller: correo,
            label: 'Correo',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 30),
          CustomTextFormField(
            label: 'Contraseña',
            obscureText: true,
            controller: password,
          ),
          const SizedBox(height: 30),
          CustomTextFormField(
            label: 'Repita la contraseña',
            obscureText: true,
            controller: repeatPassword,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CustomFilledButton(
                text: 'Recuperar contraseña',
                buttonColor: Colors.black,
                onPressed: () async {
                  String email = correo.text;
                  String pass = password.text;
                  String repPass = repeatPassword.text;
                  bool loginSuccessful = false;
                  int id = 0;

                  //* Consulta SQL
                  await db.getConnection().then((conn) async {
                    String sql = 'select idUsuario, Correo from Usuario';
                    await conn.query(sql).then((result) {
                      for (final row in result) {
                        //* Comprobación de que el correo existe
                        if (email == row[1]) {
                          if (pass == repPass) {
                            loginSuccessful = true;
                            id = row[0];
                            break;
                          }
                        }
                        //* Comprobación de las 2 contraseñas iguales
                      }
                    });

                    if (loginSuccessful) {
                      await conn.query(
                        "UPDATE Usuario SET Password = $pass WHERE idUsuario = $id",
                      );
                      await conn.close();
                      Alerts().recoverySuccessfully(context);
                      context.go('/login');
                    } else {
                      await conn.close();
                      Errors().emailDontExist(context);
                    }
                  });
                }),
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
    );
  }
}
