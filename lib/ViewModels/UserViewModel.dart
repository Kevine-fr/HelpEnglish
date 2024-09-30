import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/User.dart'; // Assure-toi que le chemin est correct

class UserViewModel extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> createUser({
    required String name,
    required String first_name,
    required String email,
    required String motDePasse,
    required String number_phone,
    required String identificator,
    required String passwordConfirmation,
  }) async {
    if (motDePasse != passwordConfirmation) {
      throw Exception('Les mots de passe ne correspondent pas');
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'first_name': first_name,
          'identificator': identificator,
          'number_phone': number_phone,
          'email': email,
          'password': motDePasse,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 201) {
      jsonDecode(response.body);
        _user = User(
          name: name,
          first_name: first_name,
          email: email,
          motDePasse: motDePasse,
          number_phone: number_phone,
          identificator: identificator,
        );
        notifyListeners();
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['error'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      throw Exception('Erreur de requête : ${e.toString()}');
    }
  }
}
