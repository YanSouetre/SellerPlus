
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _user;
  late String _userEmail = "";
  late String _userRole = "";
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
    _user = _auth.currentUser!;
    _fetchSalesData();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user.uid).get();
    setState(() {
      _userRole = userDoc['role'];
      _userEmail = userDoc['email'];
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    context.pushReplacement('/');
    // Rediriger l'utilisateur vers la page de connexion ou ailleurs
  }

  Future<void> _fetchSalesData() async {
    final QuerySnapshot salesSnapshot = await _firestore.collection('ventes').where('idCommercial', isEqualTo: _user.uid).get();


    nbVentes = salesSnapshot.size;

    // Parcourir les documents de la QuerySnapshot
    for (QueryDocumentSnapshot doc in salesSnapshot.docs) {
      final dynamic data = doc.data();

      //Prix
      price += data['price'];

      //Nombre de clients différents
      if (!clients.contains(data['client'])) {
        log(data['client']);
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
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: ${_user.email}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Role: $_userRole',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Déconnexion'),
            ),
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
                      style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.bold),
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
    );
  }
}
