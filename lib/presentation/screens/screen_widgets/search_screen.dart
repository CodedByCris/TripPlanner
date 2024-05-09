import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/widgets/travel_cards/search_card.dart';

import '../../functions/mes_mapa.dart';

class SearchScreen extends StatefulWidget {
  final Results resultViaje;
  const SearchScreen({super.key, required this.resultViaje});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Map<String, List<ResultRow>> groupedData = {};

  @override
  void initState() {
    super.initState();
    groupDataByMonth(widget.resultViaje).then((grouped) {
      setState(() {
        groupedData = grouped;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: groupedData.length,
        itemBuilder: (context, index) {
          final month = groupedData.keys.elementAt(index);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  month,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ...groupedData[month]!.map((viaje) {
                return SearchCard(
                  origen: viaje['Origen'],
                  destino: viaje['Destino'],
                  fechaSalida: viaje['FechaSalida'],
                  fechaLlegada: viaje['FechaLlegada'],
                  correoUsuario: viaje['Correo'],
                  gastos: 20,
                  numRutas: 3,
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
