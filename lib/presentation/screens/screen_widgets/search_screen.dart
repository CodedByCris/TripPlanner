import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:trip_planner/presentation/widgets/travel_cards/search_card.dart';

import '../../Database/connections.dart';
import '../../functions/mes_mapa.dart';
import '../details_screens/favorites_details.dart';

class SearchScreen extends StatefulWidget {
  final Results resultViaje;
  const SearchScreen({super.key, required this.resultViaje});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Map<String, List<ResultRow>> groupedData = {};
  Map<String, Map<String, dynamic>> userData = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final db = DatabaseHelper();
    MySqlConnection conn = await db.getConnection();

    // Obtén todos los datos de los usuarios de una vez
    final result =
        await conn.query('SELECT Correo, NombreUsuario, Imagen FROM Usuario');

    if (result.isNotEmpty) {
      for (var row in result) {
        userData[row['Correo']] = {
          'NombreUsuario': row['NombreUsuario'],
          'Imagen': row['Imagen'],
        };
      }
    }

    groupDataByMonth(widget.resultViaje).then((grouped) {
      setState(() {
        groupedData = grouped;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('SEARCH SCREEN');
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
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoriteDetails(
                          idViaje: viaje['IdViaje'],
                          correo: viaje['Correo'],
                        ),
                      ),
                    );
                  },
                  child: SearchCard(
                    origen: viaje['Origen'],
                    destino: viaje['Destino'],
                    fechaSalida: viaje['FechaSalida'],
                    fechaLlegada: viaje['FechaLlegada'],
                    correoUsuario: viaje['Correo'],
                    gastos: 20,
                    numRutas: 3,
                    userData: userData[viaje['Correo']] ?? {},
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
