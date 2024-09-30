import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:helpenglish/Views/AuthServices.dart';
import 'package:image_picker/image_picker.dart';

class DataProfessor extends StatefulWidget {
  const DataProfessor({super.key});

  @override
  State<DataProfessor> createState() => _DataProfessorState();
}

class _DataProfessorState extends State<DataProfessor> {
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
  }

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 1) // Filtre pour les professeurs
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final professors = snapshot.data?.docs ?? [];

        return Column(
          children: professors.map((professorDoc) {
            final professor = professorDoc.data() as Map<String, dynamic>;
            final professorId = professorDoc.id; // Récupère l'ID du professeur

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('conferences')
                  .where('user_id', isEqualTo: professorId) // Utilise l'ID du professeur
                  .get(),
              builder: (context, conferenceSnapshot) {
                if (conferenceSnapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const CircularProgressIndicator(),
                  );
                }

                if (conferenceSnapshot.hasError) {
                  return Text('Erreur: ${conferenceSnapshot.error}');
                }

                final conferenceCount = conferenceSnapshot.data?.docs.length ?? 0;

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
                                child: professor['profileImage'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(35),
                                        child: Image.network(
                                          professor['profileImage'],
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
                                    (professor['name'] ?? 'Pas de nom').length > 12
                                        ? (professor['name'] ?? 'Pas de nom').substring(0, 12) + '...'
                                        : professor['name'] ?? 'Pas de nom',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    professor['email'] ?? 'Pas d\'email',
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
                                    '$conferenceCount conf',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    CupertinoIcons.book,
                                    color: Colors.purple,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                professor['timestamp'] != null
                                    ? formatTimePassed(professor['timestamp'].toDate())
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
              },
            );
          }).toList(),
        );
      },
    );
  }
}
