import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpenglish/Views/AuthServices.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  Future<void> _signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Déconnexion réussie !')),
      );
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context), // Passez context ici
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _getToken(context), // Passez context ici
          child: Text('Obtenir le Token'),
        ),
      ),
    );
  }

  Future<void> _getToken(BuildContext context) async {
    try {
      String? token = await _authService.getToken();
      if (token != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token : $token')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucun utilisateur connecté')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }
}
