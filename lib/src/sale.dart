import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sellerplus/app_state.dart';
import 'package:sellerplus/component/navbar.dart';
import 'package:sellerplus/src/sell.dart';
import 'package:sellerplus/utils/string.dart';

class SalePage extends StatefulWidget {
  final String? id;

  SalePage({Key? key, this.id}) : super(key: key);

  @override
  _SaleState createState() => _SaleState();
}

class _SaleState extends State<SalePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedTechnician = "Jules";
  String saleStatus = "En attente";
  late Sells _sale;
  late Future<Sells?> _saleFuture;

  @override
  void initState() {
    super.initState();
    _saleFuture = getSaleFromid(widget.id);
  }

  Future<Sells?> getSaleFromid(String? uid) async {
    try {
      final DocumentSnapshot saleDoc =
          await _firestore.collection('ventes').doc(widget.id).get();

      final sale = Sells(
        id: saleDoc.id,
        product: saleDoc['product'],
        client: saleDoc['client'],
        date: saleDoc['date'],
        price: saleDoc['price'],
        adress: saleDoc['adress'],
        city: saleDoc['city'],
        idCommercial: saleDoc['idCommercial'],
        idTechnician: saleDoc['idTechnician'],
        statut: saleDoc['statut'],
      );

      setState(() {
        _sale = sale;
      });

      return sale;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: FutureBuilder<Sells?>(
        future: _saleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else {
              Sells? sale = snapshot.data;
              if (sale != null) {
                _sale = sale;
                return _buildSaleData();
              } else {
                return const Center(child: Text('Vente non trouvée'));
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildSaleData() {
    var appState = Provider.of<ApplicationState>(context);
    double paddingValue =
        MediaQuery.of(context).size.width > 600 ? 250.0 : 16.0;

    var user = appState.getUser;
    var role = user != null ? user["role"] : null;
    const isAldreadyValidStatus = [
      'Vendu',
      'Livré',
      'Livraison refusée',
      'Refusé'
    ];
    bool isAlreadyValid = isAldreadyValidStatus.contains(_sale.statut);

    return Scaffold(
      appBar: null,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NavBar(),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingValue),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Produit',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(_sale.product),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Client',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(_sale.client),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Lieu de livraison',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                  '${capitalize(_sale.adress)}, ${capitalize(_sale.city)}'),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Prix',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('${_sale.price} €'),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Statut',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(_sale.statut),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Technicien',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  DropdownButton<String>(
                                    value: selectedTechnician,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedTechnician = newValue!;
                                      });
                                    },
                                    items: ["Jules", "Yan"]
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (!isAlreadyValid && role == "Commercial")
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      saleStatus = "Vendu";
                                    });
                                  },
                                  child: Text('Valider la vente'),
                                ),
                              if (!isAlreadyValid && role == "Commercial")
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      saleStatus = "Refusé";
                                    });
                                  },
                                  child: Text('Refuser la vente'),
                                ),
                              if (!isAlreadyValid && role == "Technicien")
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      saleStatus = "Livrée";
                                    });
                                  },
                                  child: Text('Valider la livraison'),
                                ),
                              if (!isAlreadyValid && role == "Technicien")
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      saleStatus = "Refusée";
                                    });
                                  },
                                  child: Text('Refuser la livraison'),
                                ),
                              if (!isAlreadyValid)
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text('Valider le changement'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ])),
          ],
        ),
      ),
    );
  }
}
