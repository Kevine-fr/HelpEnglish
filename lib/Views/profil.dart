import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpenglish/Views/ProfileDetails.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:helpenglish/Views/AuthServices.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  User? _currentUser;
  Map<String, dynamic>? userData;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur : $e');
    }
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

  // Choisir une nouvelle image de profil
  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
      _uploadProfileImage();
    }
  }

  // Télécharger l'image dans Firebase Storage
  Future<void> _uploadProfileImage() async {
    if (_profileImage == null || _currentUser == null) return;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('${_currentUser!.uid}.jpg');

    try {
      await storageRef.putFile(_profileImage!);
      String downloadUrl = await storageRef.getDownloadURL();

      // Mettre à jour l'image de profil dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({'profileImage': downloadUrl});

      print('Image de profil mise à jour avec succès');
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4a235a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mon Compte',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: _pickImage, // Permet de changer l'image
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: Colors.grey,
                                ),
                                child: ClipOval(
                                  child: _profileImage != null
                                      ? Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                          width: 75,
                                          height: 75,
                                        )
                                      : (userData!['profileImage'] != null
                                          ? Image.network(
                                              userData!['profileImage'],
                                              fit: BoxFit.cover,
                                              width: 75,
                                              height: 75,
                                            )
                                          : Center(
                                              child: Text(
                                                userData!['name']
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 40,
                                                ),
                                              ),
                                            )),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff4a235a),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(3.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white60,
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Color(0xff4a235a),
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 25.0, left: 15, right: 15),
                    child: Text('Informations personnelles',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Colors.white24,
                    thickness: 0.5,
                  ),
                  _buildInfoRow('Nom', userData!['name']),
                  const Divider(color: Colors.white24, thickness: 0.5),
                  _buildInfoRow('E-mail', userData!['email']),
                  const Divider(color: Colors.white24, thickness: 0.5),
                  _buildInfoRow('Téléphone', userData!['phone']),
                  const Divider(color: Colors.white24, thickness: 0.5),
                  _buildInfoRow(
                      'Date de création',
                      (userData!['timestamp'] as Timestamp)
                          .toDate()
                          .toLocal()
                          .toString()
                          .substring(0, 10)),
                  const Divider(color: Colors.white24, thickness: 0.5),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(top: 25.0, left: 15, right: 15),
                    child: Text('Gestion de compte',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, thickness: 0.5),
                  _buildLogoutRow(),
                  const Divider(color: Colors.white24, thickness: 0.5),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15, top: 5),
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 5),
              child: Text(
                value,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ProfilDetails(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var begin = Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.easeInOut;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            ),
          icon:
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLogoutRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15, top: 5),
          child: Text(
            'Déconnexion',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        IconButton(
          onPressed: () => _signOut(context),
          icon:
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
        ),
      ],
    );
  }
}
