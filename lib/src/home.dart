import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sellerplus/app_state.dart';
import 'package:sellerplus/component/navbar.dart';

class Home extends StatefulWidget {
  final bool? loggedIn;

  const Home({super.key, this.loggedIn});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NavBar(),
          Expanded(
            child: Consumer<ApplicationState>(
              builder: (context, appState, _) => ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Text(
                    'Top 5 Sellers',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Nom')),
                      DataColumn(label: Text('Nombre de produits vendus')),
                      DataColumn(label: Text('CA')),
                      DataColumn(label: Text('Profil')),
                    ],
                    rows: appState.getTopSellers.map((seller) {
                      return DataRow(cells: [
                        DataCell(Text(seller['commercialName'])),
                        DataCell(Text(seller['productsNb'].toString())),
                        DataCell(Text(seller['totalPrice'].toString() + '€')),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.arrow_right),
                            onPressed: () {
                              var param1 = seller['idCommercial'];
                              context.go("/profile?id=$param1");
                            },
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Dernières ventes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Produit')),
                      DataColumn(label: Text('Commercial')),
                      DataColumn(label: Text('Prix convenu')),
                      DataColumn(label: Text('Fiche')),
                    ],
                    rows: appState.getLastSells.map((seller) {
                      return DataRow(cells: [
                        DataCell(Text(seller.product)),
                        DataCell(Text(seller.commercialName!)),
                        DataCell(Text(seller.price.toString() + '€')),
                        const DataCell(Icon(Icons.arrow_right)),
                      ]);
                    }).toList(),
                  ),
                  const SizedBox(height: 100),
                  const Text(
                    'Bilan mensuel',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chiffre d\'affaire : ${appState.getStats['caMonth']}€',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Nombre de produits vendus : ${appState.getStats['productSoldMonth']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bilan éternel',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chiffre d\'affaire : ${appState.getStats['caTotal']}€',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Nombre de produits vendus : ${appState.getStats['productSoldTotal']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
