import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helpenglish/Views/AuthServices.dart';
import 'package:image_picker/image_picker.dart';

class DataClient extends StatefulWidget {
  const DataClient({super.key});

  @override
  State<DataClient> createState() => _DataClientState();
}

class _DataClientState extends State<DataClient> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  User? _currentUser;
  Map<String, dynamic>? userData;
  File? _profileImage;
  List<Map<String, dynamic>> professors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchProfessorsData(); // Fetch professors' data from Firestore
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

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _fetchProfessorsData() async {
    try {
      // Fetch professors' data from Firestore (where role = 1)
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 2)
          .get();

      setState(() {
        professors = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching professors' data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
  Widget build(BuildContext context) {
    return Column(
                children: professors.map((professor) {
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
                                      (professor['name'] ?? 'Pas de nom').length > 15
                                          ? (professor['name'] ?? 'Pas de nom').substring(0, 15) + '...'
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
                }).toList(),
              
    );
  }
}
