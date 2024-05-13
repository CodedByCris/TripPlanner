import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../conf/theme/app_theme.dart';

final isDarkmodeProvider = StateProvider((ref) => false);

//Listado decolores inmutable. Crea un provider que no cambia
final colorListProvider = Provider((ref) => colorList);

//Nuevo estado
final selectedColorProvider = StateProvider((ref) => 0);

//Objeto de tipo AppTheme. Mantiene un estado pero más elaborado
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, AppTheme>((ref) => ThemeNotifier());

//Mantiene un estado
class ThemeNotifier extends StateNotifier<AppTheme> {
  //El estado = new AppTheme, es como crear un objeto del tipo AppTheme con sus variables
  ThemeNotifier() : super(AppTheme());

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void changeColorIndex(int colorIndex) {
    state = state.copyWith(selectedColor: colorIndex);
  }
}
