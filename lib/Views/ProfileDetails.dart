import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibration/vibration.dart';  // Importer la vibration

class ProfilDetails extends StatefulWidget {
  const ProfilDetails({super.key});

  @override
  State<ProfilDetails> createState() => _ProfilDetailsState();
}

class _ProfilDetailsState extends State<ProfilDetails> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  Map<String, dynamic>? userData;
  final TextEditingController _nameController = TextEditingController();

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
        _nameController.text = userData!['name']; // Initialiser le contrôleur avec le nom existant
      });
    }
  }

  Future<void> _updateUserName() async {
    final String newName = _nameController.text.trim();
    
    if (newName.isNotEmpty && newName != userData!['name']) {
      // Mettre à jour le nom dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({'name': newName});
      
      // Rafraîchir les données locales
      setState(() {
        userData!['name'] = newName;
      });
      
      // Message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nom mis à jour avec succès')),
      );
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _updateUserName,  // Mettre à jour le nom lors du clic sur "Enregistrer"
              child: const Text(
                'Enregistrer',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            )
          ],
        ),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Compte',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Text('Informations personnelles',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 18)),
                  ),
                  const SizedBox(height: 5),
                  const Divider(
                    color: Colors.white24,
                    thickness: 0.5,
                  ),
                  const SizedBox(height: 5),
                  _buildInfoRow(
                      userData!['name'],
                      userData!['email'],
                      userData!['phone'],
                      (userData!['timestamp'] as Timestamp)
                          .toDate()
                          .toLocal()
                          .toString()
                          .substring(0, 10)),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String firstValue, secodeValue, thirdValue, lastValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,  // Utiliser le contrôleur pour le nom
            decoration: InputDecoration(
              hintText: firstValue,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.black.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            decoration: InputDecoration(
              hintText: secodeValue,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              suffixIcon: Icon(Icons.lock, color: Colors.grey),
              fillColor: Colors.black.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            readOnly: true,  // Rendre le champ non modifiable
          ),
          const SizedBox(height: 15),
          TextFormField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: thirdValue,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              suffixIcon: Icon(Icons.lock, color: Colors.grey),
              fillColor: Colors.black.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            readOnly: true,  // Rendre le champ non modifiable
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Date de création : ',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              Text(
                lastValue.toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              )
            ],
          )
        ],
      ),
    );
  }
}
