import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConferenceDetailPage extends StatefulWidget {
  final String conferenceId;

  const ConferenceDetailPage({Key? key, required this.conferenceId})
      : super(key: key);

  @override
  _ConferenceDetailPageState createState() => _ConferenceDetailPageState();
}

class _ConferenceDetailPageState extends State<ConferenceDetailPage> {
  ValueNotifier<bool> isFavoriteNotifier = ValueNotifier<bool>(false);
  ValueNotifier<int> nbReservationNotifier = ValueNotifier<int>(1);

  @override
  void dispose() {
    isFavoriteNotifier.dispose();
    nbReservationNotifier.dispose();
    super.dispose();
  }

  Future<void> _reserveConference(BuildContext context) async {
    final conferenceDoc = FirebaseFirestore.instance
        .collection('conferences')
        .doc(widget.conferenceId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(conferenceDoc);
        if (!snapshot.exists) {
          throw Exception('Conférence non trouvée');
        }

        final conferenceData = snapshot.data() as Map<String, dynamic>;
        final currentInscriptionCount = conferenceData['nbrs_inscrits'] ?? 0;
        final nbReservation = nbReservationNotifier.value;

        transaction.update(
            conferenceDoc, {'nbrs_inscrits': currentInscriptionCount + nbReservation});
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Réservation réussie'),
            content: const Text('Votre réservation a été enregistrée avec succès.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: const Text('Une erreur est survenue lors de la réservation.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      print('Erreur lors de la réservation : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      bottomNavigationBar: BottomAppBar(
        color: Colors.purple[50],
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: nbReservationNotifier,
                  builder: (context, nbReservation, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Bouton "remove"
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(30)),
                          child: IconButton(
                            onPressed: () {
                              if (nbReservation > 1) {
                                nbReservationNotifier.value--;
                              }
                            },
                            icon: const Icon(Icons.remove,
                                size: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Affichage du nombre de réservations
                        Text('$nbReservation',
                            style: const TextStyle(color: Colors.black)),
                        const SizedBox(width: 15),
                        // Bouton "add"
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(30)),
                          child: IconButton(
                            onPressed: () {
                              nbReservationNotifier.value++;
                            },
                            icon: const Icon(Icons.add,
                                size: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Bouton "Passer au paiement"
              GestureDetector(
                onTap: () {
                  _reserveConference(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.purple),
                  child: const Text(
                    'Passer au paiement',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('conferences')
            .doc(widget.conferenceId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Erreur de chargement des détails'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Conférence non trouvée'));
          }
          final conference = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image de la conférence
                        Container(
                          width: double.infinity,
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.transparent,
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40)),
                            child: Image.network(
                              conference['image'] ??
                                  'https://example.com/default_image.jpg',
                              width: double.infinity,
                              height: 400,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Boutons en haut de l'image
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 35.0, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Bouton "Retour"
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white30),
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.black,
                                  ))),
                          // Bouton "Favori"
                          ValueListenableBuilder<bool>(
                            valueListenable: isFavoriteNotifier,
                            builder: (context, isFavorite, child) {
                              return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.white30),
                                  child: IconButton(
                                      onPressed: () {
                                        isFavoriteNotifier.value =
                                            !isFavoriteNotifier.value;
                                      },
                                      icon: isFavorite
                                          ? const Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            )
                                          : const Icon(
                                              Icons.favorite_outline,
                                              color: Colors.black,
                                            )));
                            },
                          ),
                        ],
                      ),
                    ),
                    // Informations sur la conférence
                    Positioned(
                      right: 0,
                      left: 0,
                      top: 295,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre et icône de localisation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  conference['title'] ?? 'Titre non spécifié',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.purple,
                                )
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Localisation
                            Text(
                              conference['location'] ??
                                  'Localisation non spécifiée',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Détails de la conférence
                Container(
                  color: Colors.purple[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Catégorie et prix
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              conference['categorie'] ?? 'Catégorie non spécifiée',
                              style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                            Text(
                              '${conference['price']?.toString() ?? 'Non spécifié'}Fcfa',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Date et heure
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          conference['date_time'] != null
                              ? (conference['date_time'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .substring(0, 10)
                              : 'Heure de la conférence non spécifiée',
                          style: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Titre "Description"
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(30)
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: EdgeInsets.all(10),
                        child: const Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          conference['description'] ?? 'Aucune description fournie.',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
