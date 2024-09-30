import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatelessWidget {
  Future<String?> _getHomePageRoute() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Obtenir le rôle de l'utilisateur depuis Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'] ?? 0;

        // Retourne le nom de la route basé sur le rôle
        if (role == 2) {
          return '/homeClient';
        } else if (role == 0) {
          return '/homeAdmin';
        } else if (role == 1) {
          return '/homeProfessor';
        }
      }
    }
    // Si aucun utilisateur n'est connecté, retourne la route de la page de connexion
    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getHomePageRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()), // Affiche un chargement
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Une erreur est survenue')),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // Utilisation de Navigator pour rediriger vers la bonne page
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, snapshot.data!);
          });
          return Container(); // Un conteneur vide pendant la navigation
        } else {
          return Scaffold(
            body: Center(child: Text('Utilisateur déconnecté.')),
          );
        }
      },
    );
  }
}
