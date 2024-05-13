//!ELIMINAR DE FAVORITOS EL VIAJE
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mysql1/mysql1.dart';
import '../Database/connections.dart';
import '../functions/mes_mapa.dart';

class TravelDataNotifier extends StateNotifier<Map<String, List<ResultRow>>> {
  final db = Mysql();
  String? correo;
  bool isDeleting = false; // Add this line

  TravelDataNotifier() : super({});

  Future<void> fetchData() async {
    String? correoTemp = await Mysql().getCorreo();
    if (correoTemp != null) {
      correo = correoTemp;
      MySqlConnection conn = await db.getConnection();

      // Use JOIN to combine Favoritos and Viaje tables
      final result = await conn.query(
          'SELECT Viaje.Origen, Viaje.Destino, Viaje.FechaSalida, Viaje.FechaLlegada, Viaje.IdViaje, Viaje.Correo FROM Favoritos JOIN Viaje ON Favoritos.IdViaje = Viaje.IdViaje WHERE Favoritos.Correo = ?',
          [correo]);

      if (result.isNotEmpty) {
        state = await groupDataByMonth(result);
      }

      db.closeConnection(conn);
    } else {
      print("Correo es nulo");
    }
  }

  Future<void> deleteTravel(int idViaje) async {
    isDeleting = true;
    MySqlConnection conn = await db.getConnection();
    await conn.query('DELETE FROM Favoritos WHERE Correo = ? AND IdViaje = ?',
        [correo, idViaje]);
    await conn.close();
    // Wait for 2 seconds before fetching data
    await Future.delayed(const Duration(seconds: 2));
    // Fetch data again after deleting a travel
    await fetchData();
    // Notify flutter_riverpod that the data has changed
    state = state;
    isDeleting = false;
  }
}

final travelDataProvider =
    StateNotifierProvider<TravelDataNotifier, Map<String, List<ResultRow>>>(
        (ref) => TravelDataNotifier());

//!CÓDIGO PARA LA CREACIÓN DEL NUEVO VIAJE
class TravelData {
  final String origen;
  final String destino;
  final String fechaSalida;
  final String fechaLlegada;
  final String notas;
  final String correo;

  TravelData({
    required this.origen,
    required this.destino,
    required this.fechaSalida,
    required this.fechaLlegada,
    required this.notas,
    required this.correo,
  });
}

class TravelDataProvider extends StateNotifier<List<TravelData>> {
  final ConnectionPool _connectionPool;

  TravelDataProvider(this._connectionPool) : super([]);

  Future<void> insertTravel(TravelData travelData) async {
    final conn = await _connectionPool.getConnection(ConnectionSettings(
      host: Mysql.host,
      user: Mysql.user,
      // Add your other connection settings here
    ));

    // Insert the travel data into the database
    await conn.query(
      'INSERT INTO Viaje(Origen, Destino, FechaSalida, FechaLlegada, NotasViaje, Correo) VALUES (?, ?, ?, ?, ?, ?)',
      [
        travelData.origen,
        travelData.destino,
        travelData.fechaSalida,
        travelData.fechaLlegada,
        travelData.notas,
        travelData.correo,
      ],
    );

    _connectionPool.releaseConnection(conn);

    // After inserting the travel, get all travels again and update the state
    List<TravelData> updatedTravelData = await getAllTravels();
    state = updatedTravelData;
  }

  Future<List<TravelData>> getAllTravels() async {
    final conn = await _connectionPool.getConnection(ConnectionSettings(
      host: Mysql.host,
      user: Mysql.user,
      // Add your other connection settings here
    ));

    // Query all travels from the database
    final result = await conn.query('SELECT * FROM Viaje');

    _connectionPool.releaseConnection(conn);

    // Convert the result into a list of TravelData
    return result.map((row) {
      return TravelData(
        origen: row['Origen'],
        destino: row['Destino'],
        fechaSalida: row['FechaSalida'],
        fechaLlegada: row['FechaLlegada'],
        notas: row['NotasViaje'],
        correo: row['Correo'],
      );
    }).toList();
  }
}
