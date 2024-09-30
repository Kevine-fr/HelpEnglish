import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpenglish/Views/Client/DetailsConference.dart';
import 'package:helpenglish/Views/ImageProfile.dart';
import 'package:helpenglish/Views/profil.dart';

class HomePageClient extends StatefulWidget {
  const HomePageClient({super.key});

  @override
  State<HomePageClient> createState() => _HomePageClientState();
}

class _HomePageClientState extends State<HomePageClient> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late Future<User?> _currentUserFuture;
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = _getCurrentUser();
    _categoriesFuture = _getCategories();
  }

  Future<User?> _getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<List<Map<String, dynamic>>> _getCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    Color mixedColor = Color.fromARGB(255, 127, 82, 183);
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                          suffixIcon: IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        HomePageClient(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var begin = Offset(0.0, 0.5);
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
                              CupertinoIcons.slider_horizontal_3,
                              color: mixedColor,
                            ),
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
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chargement des catégories
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _categoriesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child:
                                  Text('Erreur de chargement des catégories'),
                            );
                          }
                          final categories = snapshot.data ?? [];
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  List.generate(categories.length, (index) {
                                final category = categories[index];
                                IconData icon;

                                // Déterminer l'icône en fonction de l'index
                                switch (index) {
                                  case 0:
                                    icon = Icons.pie_chart;
                                    break;
                                  case 1:
                                    icon = Icons.travel_explore;
                                    break;
                                  case 2:
                                    icon = Icons.filter_list;
                                    break;
                                  case 3:
                                    icon = Icons.school;
                                    break;
                                  default:
                                    icon =
                                        Icons.trending_up; // Icône par défaut
                                    break;
                                }

                                // Vérifier si cette catégorie est sélectionnée
                                final isSelected =
                                    _selectedCategoryId == category['Titre'];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = category['Titre'];
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: isSelected
                                          ? Colors.white
                                          : Color.fromARGB(255, 127, 82, 183),
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.purple, width: 2)
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          icon,
                                          color: isSelected
                                              ? Colors.purple
                                              : Colors.white,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          category['Titre'] ?? 'Catégorie',
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.purple
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      StreamBuilder<QuerySnapshot>(
                        stream: _selectedCategoryId == null
                            ? FirebaseFirestore.instance
                                .collection('conferences')
                                .snapshots()
                            : FirebaseFirestore.instance
                                .collection('conferences')
                                .where('categorie',
                                    isEqualTo: _selectedCategoryId)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child:
                                  Text('Erreur de chargement des conférences'),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                                child: Text('Aucune conférence disponible.'));
                          }

                          final conferences = snapshot.data!.docs;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: conferences.map((conferenceDoc) {
                              final conference =
                                  conferenceDoc.data() as Map<String, dynamic>;
                              final conferenceId = conferenceDoc.id;

                              return Container(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ConferenceDetailPage(
                                                conferenceId: conferenceId),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FutureBuilder<DocumentSnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(conference['user_id'])
                                            .get(),
                                        builder: (context, userSnapshot) {
                                          if (userSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          if (userSnapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Erreur de chargement des informations utilisateur'));
                                          }
                                          final userData = userSnapshot.data
                                                      ?.data()
                                                  as Map<String, dynamic>? ??
                                              {};
                                          print(userData['profileImage']);

                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () => Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ImageProfil(
                                                                      profileImage:
                                                                          userData['profileImage']))),
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(35),
                                                          color: Colors.grey,
                                                        ),
                                                        child: ClipOval(
                                                          child: userData[
                                                                      'profileImage'] !=
                                                                  null
                                                              ? Image.network(
                                                                  userData[
                                                                      'profileImage'],
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: 40,
                                                                  height: 40,
                                                                )
                                                              : Center(
                                                                  child: Text(
                                                                    userData['name']
                                                                            ?.substring(0,
                                                                                1)
                                                                            .toUpperCase() ??
                                                                        '',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          20,
                                                                    ),
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            userData['name'] ??
                                                                'Nom de l\'utilisateur',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 2.5,
                                                          ),
                                                          Icon(Icons.verified,
                                                              color:
                                                                  Colors.blue,
                                                              size: 20),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        child: Text(
                                                          conference['title'] ??
                                                              'Titre non spécifié',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Container(
                                                        width: double.infinity,
                                                        height: 175,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Colors.grey,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: Image.network(
                                                            conference[
                                                                    'image'] ??
                                                                'https://example.com/default_image.jpg',
                                                            width:
                                                                double.infinity,
                                                            height: 175,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Image
                                                                  .asset(
                                                                'assets/images/belle.jpg',
                                                                width: double
                                                                    .infinity,
                                                                height: 175,
                                                                fit: BoxFit
                                                                    .cover,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.location_on,
                                                            color: Colors.blue,
                                                            size: 22.0,
                                                          ),
                                                          SizedBox(width: 5),
                                                          Expanded(
                                                            child: Text(
                                                              conference[
                                                                      'location'] ??
                                                                  'Lieu non spécifié',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 14,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .visible,
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
                                          );
                                        },
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                        height: 0.5,
                                      ),
                                      SizedBox(height: 15),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
