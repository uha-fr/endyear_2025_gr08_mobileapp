// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/api_config.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart'; 
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
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
      appBar: AppBar(title: Text('Accueil')),
      body: Column(
        children: [
          TextField(
              controller: _apiUrl,
              decoration: 
                    const InputDecoration(hintText: 'Enter your API Url'),
          ),
          TextField(
              controller:_apikey,
              decoration: 
                    const InputDecoration(hintText: 'Enter your API Key'),
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    } 
                    else  // Si erreur
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Connexion refusée : clé/API incorrects')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la connexion à l’API')),
                    );
                  }

               /*   Provider.of<ApiConfig>(context, listen: false).update(
                    _apikey.text,
                    _apiUrl.text,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(),
                    ),
                  );*/
                }
            } , 
            child:  const Text('Register'))
        ],
      )
    
    );
  }
}
