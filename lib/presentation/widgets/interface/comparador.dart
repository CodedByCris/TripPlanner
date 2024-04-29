import 'package:flutter/material.dart';

class ComparadorWidget extends StatefulWidget {
  const ComparadorWidget({
    super.key,
  });

  @override
  State<ComparadorWidget> createState() => _ComparadorWidgetState();
}

class _ComparadorWidgetState extends State<ComparadorWidget> {
  final formKey = GlobalKey<FormState>();
  final origenText = TextEditingController();
  final destinoText = TextEditingController();
  final precioMinText = TextEditingController();
  final precioMaxText = TextEditingController();
  final fechaSalidaText = TextEditingController();
  final fechaLlegadaText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //!Titulo
            const Text(
              'Encuentra el viaje perfecto al mejor',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            //!Subtitulo
            const Text(
              'Introduce los detalles de tu viaje y descubre las mejores actividades y ofertas',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            //!Campo de texto origen
            TextFormField(
              controller: origenText,
              decoration: const InputDecoration(
                labelText: 'ORIGEN',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una fecha de salida';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            //!Campo de texto destino
            TextFormField(
              controller: destinoText,
              decoration: const InputDecoration(
                labelText: 'DESTINO',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            //! Precio mínimo y máximo
            Row(
              children: [
                Expanded(
                  //*Minimo
                  child: TextFormField(
                    controller: precioMinText,
                    decoration: const InputDecoration(
                      labelText: 'PRECIO MIN',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 20),

                //*Maximo
                Expanded(
                  child: TextFormField(
                    controller: precioMaxText,
                    decoration: const InputDecoration(
                      labelText: 'PRECIO MAX',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //!Fecha de salida y llegada
            Row(
              children: [
                Expanded(
                  //*Salida
                  child: TextFormField(
                    controller: fechaSalidaText,
                    decoration: const InputDecoration(
                      labelText: 'FECHA SALIDA',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 20),
                //*Llegada
                Expanded(
                  child: TextFormField(
                    controller: fechaLlegadaText,
                    decoration: const InputDecoration(
                      labelText: 'FECHA LLEGADA',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            //!Botón de buscar
            ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Guarda los datos
                  String origen = origenText.text;
                  String destino = destinoText.text;
                  String precioMin = precioMinText.text;
                  String precioMax = precioMaxText.text;
                  String fechaSalida = fechaSalidaText.text;
                  String fechaLlegada = fechaLlegadaText.text;
                }
              },
              icon: const Icon(Icons.search),
              label: const Text("Buscar"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // foreground
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
