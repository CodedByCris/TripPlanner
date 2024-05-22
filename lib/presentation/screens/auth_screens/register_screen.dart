import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner/presentation/functions/snackbars.dart';

import '../../Database/connections.dart';
import '../../providers/token_provider.dart';
import '../../widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  RegisterScreen({super.key});

  final formKey = GlobalKey<FormState>();
  final correo = TextEditingController();
  final nombre = TextEditingController();
  final password = TextEditingController();

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends ConsumerState<RegisterScreen> {
  final db = DatabaseHelper();
  final _auth = FirebaseAuth.instance;

  Future<void> registerUser() async {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: widget.correo.text.trim(),
        password: widget.password.text.trim(),
      );
      await db.getConnection().then((conn) async {
        await conn
            .query('INSERT INTO Usuario(NombreUsuario, Correo) VALUES (?, ?)', [
          widget.nombre.text.trim(),
          widget.correo.text.trim(),
        ]);
        if (mounted) {
          // Check if the widget is still in the tree
          Snackbar().mensaje(context, 'Cuenta creada correctamente');
        }
        ref.read(tokenProvider.notifier).setToken(widget.correo.text);
        context.go('/home/0');
      });
    } catch (e) {
      //print(e);
      Snackbar().mensaje(context, 'Este correo ya está registrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            _RegisterForm(
                widget.formKey, widget.nombre, widget.correo, widget.password),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: CustomFilledButton(
                  text: 'Crear cuenta',
                  buttonColor: Colors.black,
                  onPressed: registerUser,
                ),
              ),
            ),
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
      ),
    );
  }
}

class _RegisterForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombre;
  final TextEditingController correo;
  final TextEditingController password;

  const _RegisterForm(this.formKey, this.nombre, this.correo, this.password);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Text('Registro', style: textStyles.titleLarge),
            const SizedBox(height: 60),
            CustomTextFormField(
              controller: nombre,
              label: 'Nombre',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            CustomTextFormField(
              controller: correo,
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su correo';
                } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Por favor ingrese un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            CustomTextFormField(
              controller: password,
              label: 'Contraseña',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su contraseña';
                } else if (value.length < 8) {
                  return 'La contraseña debe tener al menos 8 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
