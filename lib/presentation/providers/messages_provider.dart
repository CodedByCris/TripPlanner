// messages_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import '../Database/connections.dart';
import 'dart:async';

final messageProvider =
    StateNotifierProvider.family<MessageNotifier, List<ResultRow>, String>(
        (ref, idGrupo) => MessageNotifier(idGrupo));

class MessageNotifier extends StateNotifier<List<ResultRow>> {
  final db = DatabaseHelper();
  MySqlConnection? conn;
  Timer? _timer;
  String idGrupo;

  MessageNotifier(this.idGrupo) : super([]) {
    fetchData(idGrupo);
  }

  void fetchData(String idGrupo) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      conn = await db.getConnection();
      final messageResult = await conn!.query(
          'SELECT Contenido, FechaMensaje, HoraMensaje, Correo FROM Mensajes_del_Grupo WHERE IdGrupo = ?',
          [idGrupo]);
      state = messageResult.toList();
    });
  }

  Future<void> insertMessage(
      String content, String correo, String idGrupo) async {
    final date = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final timeStr = DateFormat('HH:mm').format(date);

    await conn!.query(
      'INSERT INTO Mensajes_del_Grupo (Contenido, FechaMensaje, HoraMensaje, Correo, IdGrupo) VALUES (?, ?, ?, ?, ?)',
      [content, dateStr, timeStr, correo, idGrupo],
    );

    fetchData(idGrupo);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
