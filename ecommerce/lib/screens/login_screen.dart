// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/api_config.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show utf8, base64;


class LoginScreen extends StatefulWidget {
  
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _apikey;
  late final TextEditingController _apiUrl;

  @override
  void initState(){
    _apikey = TextEditingController();
    _apiUrl = TextEditingController();
    super.initState();
  }

  @override
  void dispose(){
    _apiUrl.dispose();
    _apikey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Column(
        children: [
          TextField(
              controller: _apiUrl,
              decoration: 
                    const InputDecoration(hintText: 'Enter your prestashop Url (Eg : https://myshop.com)'),
          ),
          TextField(
              controller:_apikey,
              obscureText: true,
              decoration: 
                    const InputDecoration(hintText: 'Enter your API Key (Eg : 176383FGD79847497DD29)'),
          ),
          TextButton(
            onPressed: () async
            {
              if (_apikey.text.isNotEmpty && _apiUrl.text.isNotEmpty) {

                  // Vérifier si apikey et apiUrl correct
                  final apiKey = _apikey.text;
                  final apiUrl = _apiUrl.text;

                  final auth = 'Basic ${base64.encode(utf8.encode('$apiKey:'))}';
                  final testUrl = Uri.parse('$apiUrl');

                  try {
                    final response = await http.get(testUrl, headers: {'Authorization': auth});

                    if (response.statusCode == 200) {
                      // Met à jour le provider
                      Provider.of<ApiConfig>(context, listen: false).update(apiKey, apiUrl);

                      // Redirige vers HomeScreen
               
                      Navigator.pushReplacementNamed(context, '/home');
                    } 
                    else  // Si erreur
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Connexion refusée : ${response.statusCode}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la connexion à l’API'+'${e.toString()}')),
                    );
                  }

                }
            } , 
            child:  const Text('Login'))
        ],
      )
    
    );
  }
}
