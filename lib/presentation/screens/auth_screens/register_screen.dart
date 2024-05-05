import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner/presentation/functions/alerts.dart';
import 'package:trip_planner/presentation/functions/errors.dart';

import '../../../conf/connectivity.dart';
import '../../Database/connections.dart';
import '../../providers/token_provider.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return NetworkSensitive(
      child: Scaffold(
          body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
              ),
              child: const _RegisterForm(),
            )
          ],
        ),
      )),
    );
  }
}

class _RegisterForm extends ConsumerWidget {
  const _RegisterForm();

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = TextEditingController();
    final nombre = TextEditingController();
    final password = TextEditingController();
    final db = Mysql();
    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Text('Registro', style: textStyles.titleLarge),
          const SizedBox(height: 60),
          CustomTextFormField(
            controller: nombre,
            label: 'Nombre',
          ),
          const SizedBox(height: 30),
          CustomTextFormField(
            controller: correo,
            label: 'Correo',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 30),
          CustomTextFormField(
            controller: password,
            label: 'Contraseña',
            obscureText: true,
          ),
          const SizedBox(height: 30),
          SizedBox(
              width: double.infinity,
              height: 60,
              child: _btnCrear(correo, password, nombre, db, context, ref)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿Ya tienes cuenta?'),
              TextButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Iniciar sesión'))
            ],
          ),
        ],
      ),
    );
  }

  Widget _btnCrear(
      TextEditingController correo,
      TextEditingController password,
      TextEditingController nombre,
      Mysql db,
      BuildContext context,
      WidgetRef ref) {
    return CustomFilledButton(
        text: 'Crear cuenta',
        buttonColor: Colors.black,
        onPressed: () async {
          String email = correo.text;
          String pass = password.text;
          String name = nombre.text;

          bool loginSuccessful = true;
          await db.getConnection().then((conn) async {
            String sql = 'select Correo from Usuario';
            await conn.query(sql).then((result) {
              for (final row in result) {
                if (email == row[0]) {
                  loginSuccessful = false;
                  break;
                }
              }
            });

            if (loginSuccessful) {
              await conn.query(
                  'INSERT INTO Usuario(NombreUsuario, Correo, Password) VALUES (?, ?, ?)',
                  [name, email, pass]);
              Alerts().registerSuccessfully(context);
              await conn.close();
              storage.write(key: 'token', value: email);
              ref.read(tokenProvider.notifier).setToken(email);
              context.go('/home/0');
            } else {
              await conn.close();
              Errors().emailExist(context);
            }
          });
        });
  }
}
