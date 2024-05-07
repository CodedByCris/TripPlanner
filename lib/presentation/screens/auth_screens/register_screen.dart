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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final correo = TextEditingController();
  final nombre = TextEditingController();
  final password = TextEditingController();
  final db = Mysql();

  Future<void> registerUser() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    bool loginSuccessful = true;
    await db.getConnection().then((conn) async {
      String sql = 'select Correo from Usuario';
      await conn.query(sql).then((result) {
        for (final row in result) {
          if (correo.text == row[0]) {
            loginSuccessful = false;
            break;
          }
        }
      });

      if (loginSuccessful) {
        await conn.query(
            'INSERT INTO Usuario(NombreUsuario, Correo, Password) VALUES (?, ?, ?)',
            [nombre.text, correo.text, password.text]);
        if (mounted) {
          // Check if the widget is still in the tree
          Alerts().registerSuccessfully(context);
        }
        await conn.close();
        ref.read(tokenProvider.notifier).setToken(correo.text);
        context.go('/home/0');
      } else {
        await conn.close();
        if (mounted) {
          // Check if the widget is still in the tree
          Errors().emailExist(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return NetworkSensitive(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              const _RegisterForm(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: CustomFilledButton(
                  text: 'Crear cuenta',
                  buttonColor: Colors.black,
                  onPressed: registerUser,
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
      ),
    );
  }
}

class _RegisterForm extends ConsumerWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = TextEditingController();
    final nombre = TextEditingController();
    final password = TextEditingController();
    final textStyles = Theme.of(context).textTheme;

    final formKey = GlobalKey<FormState>();

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
