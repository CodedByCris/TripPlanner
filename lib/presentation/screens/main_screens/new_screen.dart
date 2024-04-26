import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner/presentation/providers/theme_provider.dart';

import '../../../conf/connectivity.dart';
import '../../widgets/widgets.dart';

class NewScreen extends ConsumerWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

    final formKey = GlobalKey<FormState>();
    final origenController = TextEditingController();
    final destinoController = TextEditingController();
    final fechaOrigenController = TextEditingController();
    final fechaLlegadaController = TextEditingController();
    final precioBilletesController = TextEditingController();
    List<TextEditingController> rutasControllers = [TextEditingController()];

    return NetworkSensitive(
      child: Scaffold(
        appBar: AppBar(
          title: customAppBar(
            isDarkMode: isDarkMode,
            colors: colors,
            ref: ref,
            titulo: 'NUEVO VIAJE',
          ),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              //ORIGEN

              TextFormField(
                controller: origenController,
                decoration: const InputDecoration(
                  labelText: 'Origen',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un origen';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: destinoController,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un destino';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: fechaOrigenController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de salida',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(
                      FocusNode()); // to prevent opening default keyboard
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    fechaOrigenController.text = date
                        .toIso8601String()
                        .substring(0, 10); // format the date as you want
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una fecha de salida';
                  }
                  return null;
                },
              ),
// Fecha de llegada
              TextFormField(
                controller: fechaLlegadaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de llegada',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  // existing code...
                },
                validator: (value) {
                  return null;

                  // existing code...
                },
              ),

// Precio de los billetes
              TextFormField(
                controller: precioBilletesController,
                decoration: const InputDecoration(
                  labelText: 'Precio de los billetes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  return null;

                  // existing code...
                },
              ),

              ListView.builder(
                shrinkWrap: true,
                itemCount: rutasControllers.length,
                itemBuilder: (context, index) {
                  return TextFormField(
                    controller: rutasControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Ruta ${index + 1}',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.map),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una ruta';
                      }
                      return null;
                    },
                  );
                },
              ),
              ElevatedButton(
                child: const Text('Agregar ruta'),
                onPressed: () {
                  rutasControllers.add(TextEditingController());
                },
              ),
              ElevatedButton(
                child: const Text('Guardar'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Guarda los datos
                    String origen = origenController.text;
                    String destino = destinoController.text;
                    String fechaSalida = destinoController.text;
                    String fechaLlegada = destinoController.text;
                    String precioBilletes = destinoController.text;
                    List<String> rutas = rutasControllers
                        .map((controller) => controller.text)
                        .toList();
                    print('Origen: $origen');
                    print('Destino: $destino');
                    print('Fecha de salida: $fechaSalida');
                    print('Fecha de llegada: $fechaLlegada');
                    print('Precio de los billetes: $precioBilletes');
                    print('Rutas: $rutas');
                    // Aquí puedes guardar los datos en la base de datos o en cualquier otro lugar
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
