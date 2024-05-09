import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mysql1/mysql1.dart';

Future<Map<String, List<ResultRow>>> groupDataByMonth(Results results) async {
  await initializeDateFormatting('es_ES', null);
  final Map<String, List<ResultRow>> map = {};
  for (var row in results) {
    final date = row['FechaSalida'] as DateTime;
    final month = DateFormat('MMMM', 'es_ES').format(date).toUpperCase();
    if (map[month] == null) {
      map[month] = [];
    }
    map[month]!.add(row);
  }
  return map;
}
