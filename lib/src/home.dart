import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sellerplus/component/navbar.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../data/database_service.dart';

class Home extends StatefulWidget {
  final bool? loggedIn;

  const Home({Key? key, this.loggedIn}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final DatabaseService _databaseService = DatabaseService();

  List<Map<String, dynamic>> sellers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getSellers();
  }

  void getSellers() async {
    // try {
    //   final QuerySnapshot sellsRef = await _databaseService.getCollection('ventes');
    //   for (QueryDocumentSnapshot sell in sellsRef.docs) {
    //     final dynamic data = sell.data();
    //
    //     final index = sellers.indexWhere((element) => element['idCommercial'] == data['idCommercial']);
    //     if (index != -1) {
    //       sellers[index]['totalPrice'] += data['price'];
    //       sellers[index]['productsNb'] += 1;
    //     } else {
    //       sellers.add({
    //         'idCommercial': data['idCommercial'],
    //         'totalPrice': data['totalPrice'],
    //         'productsNb': 1,
    //       });
    //     }
    //   }
    // } finally {
    //   setState(() {
    //     isLoading = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            'Top 5 Sellers',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Divider(),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : DataTable(
                  columns: [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Nombre de produits vendus')),
                    DataColumn(label: Text('CA')),
                    DataColumn(label: Text('Profil')),
                  ],
                  rows: sellers.map<DataRow>((seller) {
                    return DataRow(cells: [
                      DataCell(Text(seller['idCommercial'].toString())),
                      DataCell(Text(seller['productsNb'].toString())),
                      DataCell(Text('\$${seller['totalPrice']}')),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () {
                            // Handle profile button tap
                            print('Profile button tapped for ${seller['idCommercial']}');
                          },
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
