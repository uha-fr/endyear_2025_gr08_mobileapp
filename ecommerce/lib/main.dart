// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';      
import 'screens/products_screen.dart';  

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prestashop Manager',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: 
      {
        '/': (context) => HomeScreen(),
        '/products': (context) => ProductsScreen(),
      },
    );
  }
}
