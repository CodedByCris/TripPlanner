import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this line

import '../../functions/snackbars.dart';
import '../../widgets/widgets.dart';

class RecoverScreen extends StatefulWidget {
  const RecoverScreen({super.key});

  @override
  State<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
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
            child: const _RecoverForm(),
          )
        ],
      ),
    ));
  }
}

class _RecoverForm extends ConsumerWidget {
  const _RecoverForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Form(
        key: formKey,
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
                if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                    .hasMatch(value!)) {
                  return 'Por favor, ingrese un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _btnRecuperar(correo, context, formKey),
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

  Widget _btnRecuperar(TextEditingController correo, BuildContext context,
      GlobalKey<FormState> formKey) {
    return CustomFilledButton(
        text: 'Recuperar contraseña',
        buttonColor: Colors.black,
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            String email = correo.text.trim();

            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
              Snackbar().mensaje(context,
                  'Se ha enviado un correo para restablecer su contraseña');
            } catch (e) {
              Snackbar().mensaje(context, 'Error al enviar el correo: $e');
            }
          }
        });
  }
}
