import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helpenglish/Views/AuthServices.dart';
import 'package:image_picker/image_picker.dart';

class Datavieuw extends StatefulWidget {
  const Datavieuw({super.key});

  @override
  State<Datavieuw> createState() => _DatavieuwState();
}

class _DatavieuwState extends State<Datavieuw> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  User? _currentUser;
  Map<String, dynamic>? userData;
  File? _profileImage;

  String formatTimePassed(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return 'Date future';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return '${difference.inSeconds}s';
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchUserCounts();
    _fetchConferenceCount();
    _fetchConferences();
  }

  // Récupérer l'utilisateur actuellement connecté et ses données
  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      // Récupérer les données de l'utilisateur depuis Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int professor = 0;
  int client = 0;
  bool isLoading = true;

  Future<void> _fetchUserCounts() async {
    try {
      final role1QuerySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 1)
          .get();
      final role2QuerySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 2)
          .get();

      setState(() {
        professor = role1QuerySnapshot.docs.length;
        client = role2QuerySnapshot.docs.length;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int conferenceCount = 0;
  Future<void> _fetchConferenceCount() async {
    try {
      final querySnapshot = await _firestore.collection('conferences').get();
      setState(() {
        conferenceCount = querySnapshot.docs.length;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<QueryDocumentSnapshot> conferences = [];
  Future<void> _fetchConferences() async {
    try {
      final querySnapshot = await _firestore.collection('conferences').get();
      setState(() {
        conferences = querySnapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: conferences.map((conferenceDoc) {
        final conference = conferenceDoc.data() as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: Colors.grey[50],
                        ),
                        child: conference['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: Image.network(
                                  conference['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image,
                                        color: Colors.grey);
                                  },
                                ),
                              )
                            : const Icon(Icons.image_not_supported,
                                color: Colors.grey),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (conference['title'] ?? 'Pas de titre').length > 15
                                ? (conference['title'] ?? 'Pas de titre')
                                        .substring(0, 15) +
                                    '...'
                                : conference['title'] ?? 'Pas de titre',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            (conference['price'] ?? 'Pas de prix').toString() +
                                ' fr',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            conference['nbrs_inscrits']?.toString() ?? '0',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.bar_chart,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        conference['created_at'] != null
                            ? formatTimePassed(
                                conference['created_at'].toDate())
                            : 'Pas de date',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
