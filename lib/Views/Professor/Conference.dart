import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Conference extends StatefulWidget {
  final String conferenceId; // L'ID de la conférence à afficher

  const Conference({super.key, required this.conferenceId});

  @override
  State<Conference> createState() => _ConferenceState();
}

class _ConferenceState extends State<Conference> {
  bool isFavorite = false;
  Future<DocumentSnapshot>? _conferenceData;
  int? nbrsInscrits; 

  @override
  void initState() {
    super.initState();
    _conferenceData = _fetchConferenceData();
  }

  Future<DocumentSnapshot> _fetchConferenceData() async {
    final doc = await FirebaseFirestore.instance
        .collection('conferences')
        .doc(widget.conferenceId)
        .get();
    setState(() {
      nbrsInscrits = (doc.data()?['nbrs_inscrits'] as int?) ?? 0;
    });
    return doc;
  }

  @override
  Widget build(BuildContext context) {
    double heightImage = MediaQuery.of(context).size.height;
    double widthImage = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: _conferenceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur lors du chargement des données'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Aucune conférence trouvée'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: heightImage,
                      width: widthImage,
                      child: data['image'] != null
                          ? Image.network(
                              data['image'],
                              alignment: Alignment.topCenter,
                              width: widthImage,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'images/belle.jpg',
                              alignment: Alignment.topCenter,
                              width: widthImage,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isFavorite = !isFavorite;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.favorite,
                                        color: isFavorite ? Colors.red : Colors.white,
                                      )),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: IconButton(
                                      onPressed: () {
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      )),
                                ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: IconButton(
                                      onPressed: () {
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.pink,
                                      )),
                                ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('$nbrsInscrits',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                              ),),
                            ],
                          )
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 500
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              height: 5,
                                              width: 85,
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(10)),
                                            ),
                                            
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Titre',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                        ),
                                        Text(
                                          data['date_time'] != null
                                              ? (data['date_time'] as Timestamp).toDate().toLocal().toString().substring(0, 10)
                                              : 'Date non disponible',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    
                                    SizedBox(height: 10),
                                    Text(
                                      data['title'] ?? 'Conférence sans titre',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${data['price'] ?? '0.00'} Fcfa',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      "Description",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      data['description'] ?? 'Aucune description disponible',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Catégories'),
                                        Text(
                                      data['categorie'] ?? 'Conférence sans catégorie',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15),
                                    ),
                                      ],
                                    ),
                                    SizedBox(height: 20,),
                                    Text('Localisation',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                    SizedBox(height: 8,),
                                    Text(
                                      data['location'] ?? 'Conférence sans lieux',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
      
    );
  }
}
