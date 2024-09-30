import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpenglish/Views/Professor/AddConferences.dart';
import 'package:helpenglish/Views/AuthServices.dart';
import 'package:helpenglish/Views/Professor/Conference.dart';
import 'package:helpenglish/Views/profil.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class HomePageProfessor extends StatefulWidget {
  const HomePageProfessor({super.key});

  @override
  State<HomePageProfessor> createState() => _HomePageProfessorState();
}

class _HomePageProfessorState extends State<HomePageProfessor> {
  final AuthService _authService = AuthService();
  String? _selectedCountry;
  List<dynamic> countries = [];
  User? _currentUser;
  String? _profileImage;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
    });
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _profileImage = userDoc.data()?['profileImage'];
        _userName = userDoc.data()?['name'];
      });
    }
  }

  Future<void> _pickImage() async {
  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    setState(() {
      _profileImage = pickedImage.path; // Utiliser directement le chemin de l'image
    });
  }
}

Future<void> _uploadProfileImage(File imageFile) async {
  String fileName = _currentUser!.uid + "_profile_image";
  try {
    Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    // Mettre à jour Firestore avec la nouvelle URL
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .update({'profileImage': downloadUrl});

    setState(() {
      _profileImage = downloadUrl;
    });
  } catch (e) {
    print("Erreur lors de l'upload de l'image : $e");
  }
}


  Future<void> _fetchCountries(dynamic http) async {
    try {
      final response =
          await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
      if (response.statusCode == 200) {
        setState(() {
          countries = json.decode(response.body);
        });
      } else {
        throw Exception('Impossible de récupérer la liste des pays');
      }
    } catch (e) {
      print('Erreur lors de la récupération des pays: $e');
    }
  }

  Future<void> _showCountryPicker() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sélectionner un pays'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                final flagUrl = country['flags']['png'];
                final name = country['name']['common'];
                final callingCode = country['idd']['root'] ?? '';

                return ListTile(
                  leading: Image.network(
                    flagUrl,
                    width: 32,
                    height: 32,
                  ),
                  title: Text(name),
                  subtitle: Text('$callingCode'),
                  onTap: () {
                    setState(() {
                      _selectedCountry = "$name ($callingCode)";
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color mixedColor = Color.fromARGB(255, 127, 82, 183);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateConferencePage()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 185.0,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: mixedColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25),
                      Text(
                        'Conférence',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              Text(
                                'Sénégal, Dakar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Colors.white,
                              )
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.5, vertical: 2.5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white12),
                            child: IconButton(
                              onPressed: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      Profil(),
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
                              icon: Icon(
                                Icons.settings_suggest_outlined,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          labelStyle: TextStyle(color: Colors.grey),
                          hintText: 'Rechercher',
                          hintStyle: TextStyle(color: Colors.grey),
                          fillColor: Colors.grey[200],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: mixedColor, width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: mixedColor,
                          ),
                          suffixIcon: Icon(
                            Icons.filter_list,
                            color: mixedColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 16, left: 16),
                child: Text(
                  'Conférences',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('conferences')
                    .where('user_id',
                        isEqualTo: _currentUser?.uid) 
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Center(child: Text('Aucune conférence disponible.')),
                      ],
                    );
                  }
                  final conferences = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: conferences.length,
                    itemBuilder: (context, index) {
                      final conference =
                          conferences[index].data() as Map<String, dynamic>;
                      final conferenceId = conferences[index].id; 
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15, left: 15, bottom: 20),
                          child: Column(
                            children: [
                              Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        child: Text(
                                          conference['title'] ?? 'Sans titre',
                                          style:
                                              TextStyle(color: Colors.black, fontWeight: FontWeight.w500,),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        height: 175,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.grey,
                                        ),
                                        child: GestureDetector(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => Conference(conferenceId: conferenceId,)));
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              conference['image'] != null && conference['image']!.isNotEmpty
                                                  ? conference['image']!
                                                  : 'https://example.com/default_image.jpg',
                                              width: double.infinity,
                                              height: 175,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Center(
                                                  child: Image.network(
                                                    'https://example.com/default_image.jpg',
                                                    width: double.infinity,
                                                    height: 175,
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.blue,
                                            size: 22.0,
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              conference['location'] ?? 'Lieu non précisé',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                              overflow: TextOverflow.visible,
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                            ],
                          ),
                        ),
                      );
                      
                    },
                  );
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
