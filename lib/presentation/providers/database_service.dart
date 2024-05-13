import 'package:flutter/material.dart';

class QueryNotifier extends ChangeNotifier {
  String? _query;

  String get query => _query!;

  set query(String value) {
    _query = value;
    notifyListeners();
  }
}
