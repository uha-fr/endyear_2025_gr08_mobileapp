// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/api_config.dart';
import 'screens/home_screen.dart';      
import 'screens/login_screen.dart';      
import 'screens/products_screen.dart'; 
import 'screens/mainScaffold.dart'; 
 

void main() => runApp( 
  ChangeNotifierProvider(
      create: (_) => ApiConfig(),
      child: MyApp(),
    ),);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'Prestashop Manager',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: 
      {
        '/': (context) => LoginScreen(),
        '/home': (context) => MainScaffold(),
        '/products': (context) => ProductsScreen(),
      },
  
    );
  }
}
