import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Database/connections.dart';
import '../screens/screens.dart';

final tokenProvider =
    StateNotifierProvider<TokenNotifier, String?>((ref) => TokenNotifier());

final userNameProvider = StateNotifierProvider<UserNameNotifier, String?>(
    (ref) => UserNameNotifier());

final imageProvider =
    StateNotifierProvider<ImageNotifier, String?>((ref) => ImageNotifier());

final favoriteTripsProvider = StateNotifierProvider<FavoriteTripsNotifier, int>(
    (ref) => FavoriteTripsNotifier());

final completedTripsProvider =
    StateNotifierProvider<CompletedTripsNotifier, int>(
        (ref) => CompletedTripsNotifier());

//!PARA SACAR EL NOMBRE DEL USUARIO
class UserNameNotifier extends StateNotifier<String?> {
  UserNameNotifier() : super(null) {
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String userName = "";
    final correo = await getToken();
    //print("Correo del provider -> $correo");
    DatabaseHelper db = DatabaseHelper();

    await db.getConnection().then((conn) async {
      String sql = 'select NombreUsuario from Usuario Where Correo="$correo"';
      await conn.query(sql).then((result) {
        for (final row in result) {
          userName = row[0];
          break;
        }
      });
      state = userName;
    });
  }

  Future<void> refresh() async {
    _loadUserName();
  }
}

//!PARA SACAR LA IMAGEN DEL USUARIO
class ImageNotifier extends StateNotifier<String?> {
  ImageNotifier() : super(null) {
    _loadImage();
  }

  Future<void> _loadImage() async {
    String? imagen;
    final correo = await getToken();
    //print("Correo del provider -> $correo");
    DatabaseHelper db = DatabaseHelper();

    await db.getConnection().then((conn) async {
      String sql = 'select Imagen from Usuario Where Correo="$correo"';
      await conn.query(sql).then((result) {
        for (final row in result) {
          imagen = row[0];
          break;
        }
      });

      state = imagen;
    });
  }

  Future<void> refresh() async {
    _loadImage();
  }
}

//!PARA SACAR LOS VIAJES FAVORITOS DEL USUARIO
class FavoriteTripsNotifier extends StateNotifier<int> {
  FavoriteTripsNotifier() : super(0) {
    _loadFavoriteTrips();
  }

  Future<void> _loadFavoriteTrips() async {
    final correo = await getToken();
    DatabaseHelper db = DatabaseHelper();

    await db.getConnection().then((conn) async {
      String sql = 'select count(*) from Favoritos Where Correo="$correo"';
      await conn.query(sql).then((result) {
        for (final row in result) {
          state = row[0];
          break;
        }
      });
    });
  }

  Future<void> refresh() async {
    _loadFavoriteTrips();
  }
}

//! PARA SACAR LOS VIAJES COMPLETADOS DEL USUARIO
class CompletedTripsNotifier extends StateNotifier<int> {
  CompletedTripsNotifier() : super(0) {
    _loadCompletedTrips();
  }

  Future<void> _loadCompletedTrips() async {
    final correo = await getToken();
    DatabaseHelper db = DatabaseHelper();

    await db.getConnection().then((conn) async {
      print("Correo->${correo!}");
      String sql = 'select count(*) from Viaje Where Correo="$correo"';
      await conn.query(sql).then((result) {
        for (final row in result) {
          state = row[0];
          break;
        }
      });
    });
  }

  Future<void> refresh() async {
    _loadCompletedTrips();
  }
}

//! PARA SACAR EL CORREO DEL USUARIO
class TokenNotifier extends StateNotifier<String?> {
  TokenNotifier() : super(null) {
    loadToken();
  }

  Future<void> loadToken() async {
    state = await getToken();
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'token');
    state = null;
  }

  Future<void> setToken(String token) async {
    await storage.write(key: 'token', value: token);
    state = token;
  }
}
