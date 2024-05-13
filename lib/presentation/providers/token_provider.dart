import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Database/connections.dart';
import '../screens/screens.dart';

final tokenProvider =
    StateNotifierProvider<TokenNotifier, String?>((ref) => TokenNotifier());

final userNameProvider = StateNotifierProvider<UserNameNotifier, String?>(
    (ref) => UserNameNotifier());

final imageProvider =
    StateNotifierProvider<ImageNotifier, String?>((ref) => ImageNotifier());

//!PARA SACAR EL NOMBRE DEL USUARIO
class UserNameNotifier extends StateNotifier<String?> {
  UserNameNotifier() : super(null) {
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String userName = "";
    final correo = await getToken();
    print("Correo del provider -> $correo");
    Mysql db = Mysql();

    await db.getConnection().then((conn) async {
      String sql = 'select NombreUsuario from Usuario Where Correo="$correo"';
      await conn.query(sql).then((result) {
        for (final row in result) {
          userName = row[0];
          break;
        }
      });
      db.closeConnection(conn);
      print("Nombre del provider -> $userName");
      state = userName;
    });
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
    print("Correo del provider -> $correo");
    Mysql db = Mysql();

    await db.getConnection().then((conn) async {
      String sql = 'select Imagen from Usuario Where Correo="$correo"';
      await conn.query(sql).then((result) {
        for (final row in result) {
          imagen = row[0];
          break;
        }
      });
      db.closeConnection(conn);

      print("Imagen del provider -> $imagen");
      state = imagen;
    });
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
