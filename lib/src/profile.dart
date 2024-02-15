
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sellerplus/component/navbar.dart';

import '../app_state.dart';

class ProfilePage extends StatefulWidget {
  String? id;
  ProfilePage({super.key, this.id});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _userId;
  late String _userRole = "";
  late String _userEmail = "";
  List<String> clients = [];
  int nbclient = 0;
  DateTime date = DateTime.now();
  num price = 0;
  String product = "";
  Map<String, int> productCounts = {};
  String mostSoldProduct = '';
  int maxCount = 0;
  int nbVentes = 0;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    String user = await getUserFromUid(widget.id);

    setState(() {
      _userId = user;
    });
    await _loadUserData();
    await _fetchSalesData();
    }

  Future<void> _loadUserData() async {
    final DocumentSnapshot userDoc = await _firestore.collection('users').doc(_userId).get();
    setState(() {
      _userRole = userDoc['role'];
      _userEmail = userDoc['email'];
    });
  }

  Future<String> getUserFromUid(String? uid) async {
    try {
      // Utilisez la méthode getUser pour récupérer l'utilisateur avec l'UID spécifié
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.id).get();
      return userDoc.id;
        } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return "null";
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    context.pushReplacement('/');
    // Rediriger l'utilisateur vers la page de connexion ou ailleurs
  }

  Future<void> _fetchSalesData() async {
    final QuerySnapshot salesSnapshot = await _firestore.collection('ventes').where('idCommercial', isEqualTo: _userId).get();


    nbVentes = salesSnapshot.size;

    // Parcourir les documents de la QuerySnapshot
    for (QueryDocumentSnapshot doc in salesSnapshot.docs) {
      final dynamic data = doc.data();

      //Prix
      price += data['price'];

      //Nombre de clients différents
      if (!clients.contains(data['client'])) {
        // Ajouter le nom du client à la liste
        nbclient += 1;
        clients.add(data['client']);
      }

      // Convertir la date Firestore en DateTime
      final DateTime saleDate = data['date'].toDate();

      // Mettre à jour la date la plus ancienne si nécessaire
      if (saleDate.compareTo(date) < 0) {
        date = saleDate;
      }

      // Accéder au produit dans le document
      product = data['product'];

      // Incrémenter le compteur du produit dans le Map
      productCounts.update(product, (value) => value + 1, ifAbsent: () => 1);

    }
    productCounts.forEach((product, count) {
      if (count > maxCount) {
        mostSoldProduct = product;
        maxCount = count;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: FutureBuilder<String?>(
        future: getUserFromUid(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Afficher un indicateur de chargement tant que les données ne sont pas disponibles
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              // Afficher un message d'erreur s'il y a eu une erreur lors de la récupération des données
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else {
              // Les données sont disponibles, vous pouvez les utiliser ici
              String? userId = snapshot.data;
              if (userId != null) {
                _userId = userId; // Assurez-vous que _user est initialisé avant de l'utiliser
                return _buildUserData();
              } else {
                return Center(child: Text('Utilisateur non trouvé'));
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildUserData() {
    var appState = Provider.of<ApplicationState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NavBar(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                const CircleAvatar(
                      radius: 85, // Change this radius for the width of the circular border
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 85, // This radius is the radius of the picture in the circle avatar itself.
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1517849845537-4d257902454a?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        ),
                      ),
                    ),
                Column(
                  children: [
                    Text(
                      '$_userEmail',
                      style: TextStyle(fontSize: 25,
                      fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$_userRole',
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(height: 20),
                    _userId == appState.getUser["uid"]
                        ? ElevatedButton.icon(
                      onPressed: _logout,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Définit la couleur de fond du bouton sur rouge
                      ),
                      icon: Icon(Icons.logout, color: Colors.white), // Ajoute une icône de déconnexion à gauche du texte
                      label: Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.white), // Définit la couleur du texte sur blanc
                      ),
                    )

                        : SizedBox(),
                  ],
                ),
              ],
            ),
              SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20, // Espacement horizontal entre les éléments
                runSpacing: 20, // Espace
                children: [
                  Column(
                    children: [
                      Text(
                        'Nombre de clients différents',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$nbclient',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Prix total des ventes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$price',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Produit le plus vendu',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$mostSoldProduct',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Nombre de ventes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$nbVentes',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
