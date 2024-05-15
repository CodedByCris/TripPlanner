import 'package:flutter/material.dart';

//This screen is to show when there is no internet connection
class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.signal_wifi_off, size: 100, color: Colors.red),
              SizedBox(height: 20),
              Text(
                "No tienes conexión a internet",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Cuando dispongas de conexión a internet, la pantalla se recargará automáticamente",
                style: TextStyle(fontSize: 20, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Comprueba que tienes activado el wifi o los datos móviles",
                style: TextStyle(fontSize: 15, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
