import 'package:flutter/material.dart';

class ComparadorWidget extends StatefulWidget {
  const ComparadorWidget({
    super.key,
  });

  @override
  State<ComparadorWidget> createState() => _ComparadorWidgetState();
}

class _ComparadorWidgetState extends State<ComparadorWidget> {
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
            const Text(
              'Encuentra el viaje perfecto al mejor',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Introduce los detalles de tu viaje y descubre las mejores actividades y ofertas',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: origenText,
              decoration: const InputDecoration(
                labelText: 'ORIGEN',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: destinoText,
              decoration: const InputDecoration(
                labelText: 'DESTINO',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
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
            Row(
              children: [
                Expanded(
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
            ElevatedButton.icon(
              onPressed: () {},
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
