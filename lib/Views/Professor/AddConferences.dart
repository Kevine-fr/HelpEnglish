import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateConferencePage extends StatefulWidget {
  @override
  _CreateConferencePageState createState() => _CreateConferencePageState();
}

class _CreateConferencePageState extends State<CreateConferencePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController(); // Ajout du contrôleur pour la date et l'heure
  DateTime? selectedDateTime;
  File? _image;
  bool _isLoading = false;
  String? _selectedCategory;
  List<String> _categories = [];

  // Demande de permissions pour la caméra et le stockage
  Future<void> _requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted && storageStatus.isGranted) {
      _pickImage(); // Lance la sélection d'image
    } else {
      _showPermissionDialog(
          context); // Affiche une alerte pour activer les permissions
    }
  }

  // Affiche une alerte pour diriger vers les paramètres de l'application
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permissions manquantes"),
          content: Text(
              "Veuillez activer les permissions pour la caméra et le stockage dans les paramètres."),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings(); // Ouvre les paramètres de l'application
                Navigator.of(context).pop();
              },
              child: Text("Ouvrir les paramètres"),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _getCategories() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
    List<String> categories = [];
    snapshot.docs.forEach((doc) {
      categories.add(doc['Titre']); 
    });
    return categories;
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    List<String> categories = await _getCategories();
    setState(() {
      _categories = categories;
    });
  }

  // Sélection d'une image depuis la galerie
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Aucune image sélectionnée.')));
    }
  }

  // Téléchargement de l'image sur Firebase Storage
  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageRef =
          FirebaseStorage.instance.ref().child('conference_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Erreur lors du téléchargement de l\'image. Veuillez vérifier les permissions.')));
      return null;
    }
  }

  // Création de la conférence dans Firestore
  Future<void> _createConference() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Veuillez sélectionner une image.')));
        return;
      }

      if (selectedDateTime == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Veuillez sélectionner une date et une heure.')));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Utilisateur non connecté.')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      final conferenceData = {
        'user_id': user.uid,
        'title': titleController.text,
        'description': descriptionController.text,
        'location': locationController.text,
        'date_time': selectedDateTime,
        'image': imageUrl,
        'nbrs_inscrits': 0,
        'price': double.parse(priceController.text),
        'categorie': _selectedCategory, // Ajout de la catégorie
        'created_at': DateTime.now(),
        'updated_at': DateTime.now(),
      };

      await FirebaseFirestore.instance
          .collection('conferences')
          .add(conferenceData);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conférence créée avec succès !')));
      Navigator.pop(context); // Retour à la page précédente
    }
  }

  // Affiche un sélecteur de date et d'heure
  Future<void> _selectDateTime(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          dateTimeController.text = '${selectedDateTime!.toLocal()}'.split(' ')[0] +
              ' ' +
              '${selectedDateTime!.hour}:${selectedDateTime!.minute}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double heightImage = MediaQuery.of(context).size.height;
    double widthImage = MediaQuery.of(context).size.width;
    double containerContent = heightImage * 0.35;
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(
          children: [
            Container(
              height: heightImage,
              width: widthImage,
              child: _image == null
                ? Image.asset(
                    'images/notimage.png',
                    alignment: Alignment.topCenter,
                    scale: 0.1,
                  )
                : Image.file(
                    _image!,
                    alignment: Alignment.topCenter,
                    scale: 0.1,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(35)),
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
                          borderRadius: BorderRadius.circular(35)),
                      child: IconButton(
                          onPressed: _requestPermissions,
                          icon: Icon(
                            Icons.image_search,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: containerContent,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white
                ),
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(labelText: 'Titre'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un titre';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 5,),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(labelText: 'Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 5,),
                        TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: 'Localisation',
                            suffixIcon: Icon(Icons.location_on)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un emplacement';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 5,),
                        TextFormField(
                          controller: priceController,
                          decoration: InputDecoration(labelText: 'Prix'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un prix';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 5,),
                        TextFormField(
                          controller: dateTimeController,
                          decoration: InputDecoration(
                            labelText: 'Date et Heure',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () => _selectDateTime(context),
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner une date et une heure';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 5,),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          hint: Text('Sélectionner une catégorie'),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner une catégorie';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _isLoading
                            ? CircularProgressIndicator()
                            : Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _createConference,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Center( // Ajoute un Center pour centrer le texte
                                          child: Text(
                                            'Créer la conférence',
                                            style: TextStyle(color: Colors.white), // Pour améliorer la visibilité
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
