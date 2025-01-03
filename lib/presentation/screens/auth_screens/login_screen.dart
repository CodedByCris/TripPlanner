// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../functions/snackbars.dart';
import '../../providers/token_provider.dart';
import '../../widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Colors.black, Color.fromARGB(255, 103, 103, 103)],
            ),
            image: DecorationImage(
              image: AssetImage('assets/images/cielo.jpg'),
              opacity: 0.6, // Replace with your image
              fit: BoxFit.cover,
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(100)),
                ),
                child: const _LoginForm(),
              )
            ],
          ),
        ),
      ],
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
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Logo.png'),
                  opacity: 1, // Replace with your image
                  fit: BoxFit.contain,
                ),
              ),
            ),
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
                } else if (value.length < 3) {
                  return "La contraseña debe tener al menos 3 letras";
                }
                // Add password validation here
                return null;
              },
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: _btnIniciar(correo, password, ref, context, formKey),
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
        const Text(
          '¿No tienes cuenta?',
          style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        TextButton(
            onPressed: () => context.push('/register'),
            child: const Text(
              'Crea una aquí',
              style: TextStyle(
                  color: Color.fromARGB(255, 140, 234, 255),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ))
      ],
    );
  }

  Row _recover(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
            onPressed: () => context.push('/recover'),
            child: const Text(
              'Recuperar contraseña',
              style: TextStyle(
                  color: Color.fromARGB(255, 140, 234, 255),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ))
      ],
    );
  }

  SizedBox _invitado(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color.fromARGB(212, 255, 0, 0), // Fondo blanco
          side: const BorderSide(color: Colors.black, width: 2), // Borde negro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Bordes redondeados
          ),
        ),
        child: const Text(
          'Entrar como invitado',
          style: TextStyle(color: Colors.white), // Texto negro
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
      WidgetRef ref,
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

            try {
              // Sign in the user with Firebase Authentication
              final UserCredential userCredential =
                  await _auth.signInWithEmailAndPassword(
                email: email,
                password: pass,
              );
              Snackbar().mensaje(context, "Sesión iniciada correctamente");

              await storage.write(key: 'token', value: email);

              // Verificar el token después de escribirlo
              getToken().then((token) {
                if (token != null) {
                  try {
                    context.go('/home/0');
                    // Notify the tokenProvider of the change
                    ref.read(tokenProvider.notifier).setToken(
                        token); // Usa ref.read en lugar de context.read

                    ref.read(userNameProvider.notifier).refresh();
                    ref.read(imageProvider.notifier).refresh();
                    ref.read(favoriteTripsProvider.notifier).refresh();
                    ref.read(completedTripsProvider.notifier).refresh();
                  } catch (e) {
                    if (e is NoSuchMethodError) {
                      // El widget ha sido desmontado, no hacer nada
                    } else {
                      rethrow;
                    }
                  }
                }
              });
            } on FirebaseAuthException catch (e) {
              String message;
              if (e.code == 'user-not-found') {
                message = 'Los datos introducidos son incorrectos.';
              } else if (e.code == 'wrong-password') {
                message = 'Los datos introducidos son incorrectos.';
              } else {
                message = 'Los datos introducidos son incorrectos.';
              }
              Snackbar().mensaje(context, message);
            } catch (e) {
              Snackbar()
                  .mensaje(context, "Los datos introducidos son incorrectos");
            }
          }
        });
  }
}
