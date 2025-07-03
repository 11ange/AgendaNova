import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue, // Cor primária do aplicativo
    brightness: Brightness.light, // Tema claro
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue, // Cor de fundo da AppBar
      foregroundColor: Colors.white, // Cor do texto e ícones na AppBar
      elevation: 4, // Sombra da AppBar
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blueAccent, // Cor do FloatingActionButton
      foregroundColor: Colors.white, // Cor do ícone do FloatingActionButton
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Cor de fundo dos botões elevados
        foregroundColor: Colors.white, // Cor do texto dos botões elevados
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Borda arredondada para botões
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // Borda arredondada para campos de texto
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(fontSize: 14), // Ajuste para labels de input
      hintStyle: const TextStyle(fontSize: 14), // Ajuste para hints de input
    ),
    cardTheme: CardThemeData(
      elevation: 2, // Sombra dos cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Borda arredondada para cards
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black87), // Reduzido de 24 para 20
      titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black87), // Reduzido de 20 para 16
      titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black87), // Adicionado/Ajustado
      bodyLarge: TextStyle(fontSize: 14.0, color: Colors.black87), // Reduzido de 16 para 14
      bodyMedium: TextStyle(fontSize: 12.0, color: Colors.black54), // Reduzido de 14 para 12
      bodySmall: TextStyle(fontSize: 10.0, color: Colors.black54), // Adicionado/Ajustado
      labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.white), // Ajustado
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Colors.amber),
  );

  // Você pode definir um tema escuro aqui se desejar
  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    // ... configurações de tema escuro
  );
}