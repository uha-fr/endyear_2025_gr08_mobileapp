import 'package:flutter/material.dart';

class ApiConfig extends ChangeNotifier {
  String _apiKey = '';
  String _apiUrl = '';

  String get apiKey => _apiKey;
  String get apiUrl => _apiUrl;

  void update(String apiKey, String apiUrl) 
  {
    _apiKey = apiKey.trim();
    _apiUrl = apiUrl.trim();
    notifyListeners();
  }
}