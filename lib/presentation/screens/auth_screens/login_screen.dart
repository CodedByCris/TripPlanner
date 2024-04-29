import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../conf/connectivity.dart';
import '../../functions/connections.dart';
import '../../providers/token_provider.dart';
import '../../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return NetworkSensitive(
      child: Scaffold(
          body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
              ),
              child: const _LoginForm(),
            )
          ],
        ),
      )),
    );
  }
}

const FlutterSecureStorage storage = FlutterSecureStorage();

Future<String?> getToken() async {
  return await storage.read(key: 'token');
}

Future<String?> deleteToken() async {
  await storage.delete(key: 'token');
  return null;
}

class _LoginForm extends ConsumerWidget {
  const _LoginForm();

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = TextEditingController();
    final password = TextEditingController();
    final textStyles = Theme.of(context).textTheme;
    final db = Mysql();

    //* Guardo en la variable correo, el correo que tiene el usuario para hacer las queries
    getToken().then((token) {
      if (token != null) {
        context.go('/home/0');
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Text('Login', style: textStyles.titleLarge),
          const SizedBox(height: 50),
          CustomTextFormField(
            label: 'Correo',
            keyboardType: TextInputType.emailAddress,
            controller: correo,
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            label: 'Contraseña',
            obscureText: true,
            //validator: (p0)
            controller: password,
          ),

          //! Botón de iniciar sesión
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomFilledButton(
              text: 'Iniciar sesión',
              buttonColor: Colors.black,
              onPressed: () async {
                String email = correo.text;
                String pass = password.text;
                bool loginSuccessful = false;

                await db.getConnection().then((conn) async {
                  String sql = 'select Correo, Password from Usuario';
                  await conn.query(sql).then((result) {
                    for (final row in result) {
                      if (email == row[0] && pass == row[1]) {
                        loginSuccessful = true;
                        break;
                      }
                    }
                  });
                  await conn.close();
                });

                if (loginSuccessful) {
                  storage.write(key: 'token', value: email);
                  ref.read(tokenProvider.notifier).setToken(email);

                  context.go('/home/0');
                } else {
                  const snackbar =
                      SnackBar(content: Text('El usuario no existe'));
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                }
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          //!Entrar como invitado
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(176, 255, 0, 0), // Fondo blanco
                side: const BorderSide(
                    color: Colors.black, width: 2), // Borde negro
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
                ),
              ),
              child: const Text(
                'Entrar como invitado',
                style: TextStyle(color: Colors.black), // Texto negro
              ),
              onPressed: () async {
                context.go('/home/0');
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () => context.push('/recover'),
                  child: const Text('Recuperar contraseña'))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿No tienes cuenta?'),
              TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Crea una aquí'))
            ],
          ),
        ],
      ),
    );
  }
}
