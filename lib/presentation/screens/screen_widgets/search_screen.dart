import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/widgets/travel_cards/search_card.dart';

class SearchScreen extends StatefulWidget {
  final Results resultViaje;
  const SearchScreen({super.key, required this.resultViaje});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados de la consulta'),
      ),
      body: ListView.builder(
        itemCount: widget.resultViaje.length,
        itemBuilder: (context, index) {
          var viaje = widget.resultViaje.elementAt(index);
          return SearchCard(
            origen: viaje['Origen'],
            destino: viaje['Destino'],
            fechaSalida: viaje['FechaSalida'],
            fechaLlegada: viaje['FechaLlegada'],
          );
        },
      ),
    );
  }
}
