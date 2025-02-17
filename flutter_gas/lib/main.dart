import 'package:flutter/material.dart';
import 'screens/SensoresScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensores App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SensoresScreen(), // Mostramos la pantalla de sensores
    );
  }
}
