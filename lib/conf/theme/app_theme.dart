import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//* Lista de colores para elegir el tema
const colorList = <Color>[
  Color.fromARGB(255, 58, 33, 243),
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.purple,
  Colors.deepPurple,
  Colors.yellow,
  Colors.red,
  Colors.pinkAccent
];

class AppTheme {
  final int selectedColor;
  final bool isDarkMode;

  AppTheme({this.selectedColor = 0, this.isDarkMode = false})
      : assert(selectedColor >= 0, "Selected color must be greater then 0"),
        assert(selectedColor < colorList.length,
            "Selected color must be less then ${colorList.length - 1}");

  ThemeData getTheme() => ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorSchemeSeed: colorList[selectedColor],

      ///* Texts
      textTheme: TextTheme(
          titleLarge: GoogleFonts.montserratAlternates()
              .copyWith(fontSize: 40, fontWeight: FontWeight.bold),
          titleMedium: GoogleFonts.montserratAlternates()
              .copyWith(fontSize: 30, fontWeight: FontWeight.bold),
          titleSmall:
              GoogleFonts.montserratAlternates().copyWith(fontSize: 20)),

      ///* Buttons
      filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
              textStyle: MaterialStatePropertyAll(
                  GoogleFonts.montserratAlternates()
                      .copyWith(fontWeight: FontWeight.w700)))),

      ///* AppBar
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.montserratAlternates().copyWith(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
      ));

  //Método que regresa el mismo AppTheme
  AppTheme copyWith({int? selectedColor, bool? isDarkMode}) => AppTheme(
        //Si me dan un valor, lo igualo, sino cojo el anterior
        selectedColor: selectedColor ?? this.selectedColor,
        isDarkMode: isDarkMode ?? this.isDarkMode,
      );
}
