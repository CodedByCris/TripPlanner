import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../Database/connections.dart';
import '../../functions/snackbars.dart';
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
    return Scaffold(
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
    ));
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = TextEditingController();
    final password = TextEditingController();
    final textStyles = Theme.of(context).textTheme;
    final db = DatabaseHelper();
    final formKey = GlobalKey<FormState>(); // Agrega esta línea

    getToken().then((token) {
      if (token != null) {
        context.go('/home/0');
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        // Agrega esta línea
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text('Login', style: textStyles.titleLarge),
            const SizedBox(height: 50),
            CustomTextFormField(
                label: 'Correo',
                keyboardType: TextInputType.emailAddress,
                controller: correo,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su correo';
                  } else if (!RegExp(
                          r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                      .hasMatch(value)) {
                    return 'Por favor, ingrese un correo válido';
                  }
                  return null;
                }),
            const SizedBox(height: 20),
            CustomTextFormField(
              label: 'Contraseña',
              obscureText: true,
              controller: password,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese su contraseña';
                }
                // Add password validation here
                return null;
              },
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: _btnIniciar(correo, password, db, ref, context, formKey),
            ),
            const SizedBox(
              height: 20,
            ),

            //!Entrar como invitado
            _invitado(context),
            const SizedBox(height: 20),
            _recover(context),
            register(context),
          ],
        ),
      ),
    );
  }

  Row register(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('¿No tienes cuenta?'),
        TextButton(
            onPressed: () => context.push('/register'),
            child: const Text('Crea una aquí'))
      ],
    );
  }

  Row _recover(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
            onPressed: () => context.push('/recover'),
            child: const Text('Recuperar contraseña'))
      ],
    );
  }

  SizedBox _invitado(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color.fromARGB(176, 255, 0, 0), // Fondo blanco
          side: const BorderSide(color: Colors.black, width: 2), // Borde negro
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
    );
  }

  Widget _btnIniciar(
      TextEditingController correo,
      TextEditingController password,
      DatabaseHelper db,
      WidgetRef ref, // Agrega este parámetro
      BuildContext context,
      GlobalKey<FormState> formKey) {
    return CustomFilledButton(
        text: 'Iniciar sesión',
        buttonColor: Colors.black,
        onPressed: () async {
          // Validate the inputs
          if (formKey.currentState!.validate()) {
            // If the inputs are valid, do the login
            String email = correo.text.trim();
            String pass = password.text.trim();
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
            });

            if (loginSuccessful) {
              Snackbar().mensaje(context, 'Sesión iniciada correctamente');
              await storage.write(key: 'token', value: email);
              print('Guardo el token');

              // Verificar el token después de escribirlo
              getToken().then((token) {
                if (token != null) {
                  try {
                    context.go('/home/0');
                    // Notify the tokenProvider of the change
                    ref.read(tokenProvider.notifier).setToken(
                        token); // Usa ref.read en lugar de context.read
                  } catch (e) {
                    if (e is NoSuchMethodError) {
                      // El widget ha sido desmontado, no hacer nada
                    } else {
                      rethrow;
                    }
                  }
                }
              });
            } else {
              const snackbar = SnackBar(content: Text('El usuario no existe'));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            }
          }
        });
  }
}
