import 'package:flutter/material.dart';

class ComparadorWidget extends StatefulWidget {
  const ComparadorWidget({
    super.key,
  });

  @override
  State<ComparadorWidget> createState() => _ComparadorWidgetState();
}

class _ComparadorWidgetState extends State<ComparadorWidget> {
  GlobalKey<FormState>? formKey;
  TextEditingController? origenText;
  TextEditingController? destinoText;
  TextEditingController? precioMinText;
  TextEditingController? precioMaxText;
  TextEditingController? fechaSalidaText;
  TextEditingController? fechaLlegadaText;

  @override
  void initState() {
    formKey = GlobalKey<FormState>();
    origenText = TextEditingController();
    destinoText = TextEditingController();
    precioMinText = TextEditingController();
    precioMaxText = TextEditingController();
    fechaSalidaText = TextEditingController();
    fechaLlegadaText = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
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
              _origen(colors),
              const SizedBox(height: 20),

              //!Campo de texto destino
              _destino(colors),
              const SizedBox(height: 20),

              //! Precio mínimo y máximo
              _precio(colors),
              const SizedBox(height: 20),

              //!Fecha de salida y llegada
              fechas(colors),
              const SizedBox(height: 50),

              //!Botón de buscar
              _btnBuscar(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _precio(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          //*Minimo
          child: TextFormField(
            controller: precioMinText,
            decoration: InputDecoration(
              labelText: 'PRECIO MIN',
              prefixIcon: Icon(
                Icons.attach_money,
                color: colors.primary,
              ),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 20),

        //*Maximo
        Expanded(
          child: TextFormField(
            controller: precioMaxText,
            decoration: InputDecoration(
              labelText: 'PRECIO MAX',
              prefixIcon: Icon(
                Icons.attach_money,
                color: colors.primary,
              ),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _btnBuscar(ColorScheme colors) {
    return ElevatedButton.icon(
      onPressed: () {
        if (formKey != null && formKey!.currentState!.validate()) {
          // Guarda los datos
          String origen = origenText!.text;
          String destino = destinoText!.text;
          String precioMin = precioMinText!.text;
          String precioMax = precioMaxText!.text;
          String fechaSalida = fechaSalidaText!.text;
          String fechaLlegada = fechaLlegadaText!.text;
        }
      },
      icon: const Icon(Icons.search),
      label: const Text("Buscar"),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: colors.primary, // foreground
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        textStyle: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget fechas(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          //*Salida
          child: TextFormField(
            controller: fechaSalidaText,
            decoration: InputDecoration(
              labelText: 'FECHA SALIDA',
              prefixIcon: Icon(
                Icons.calendar_today,
                color: colors.primary,
              ),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.datetime,
          ),
        ),
        const SizedBox(width: 20),
        //*Llegada
        Expanded(
          child: TextFormField(
            controller: fechaLlegadaText,
            decoration: InputDecoration(
              labelText: 'FECHA LLEGADA',
              prefixIcon: Icon(
                Icons.calendar_today,
                color: colors.primary,
              ),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.datetime,
          ),
        ),
      ],
    );
  }

  Widget _destino(ColorScheme colors) {
    return TextFormField(
      controller: destinoText,
      decoration: InputDecoration(
        labelText: 'DESTINO',
        prefixIcon: Icon(
          Icons.location_on,
          color: colors.primary,
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _origen(ColorScheme colors) {
    return TextFormField(
      controller: origenText,
      decoration: InputDecoration(
        labelText: 'ORIGEN',
        prefixIcon: Icon(
          Icons.location_on,
          color: colors.primary,
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese un punto de origen';
        }
        return null;
      },
    );
  }
}
