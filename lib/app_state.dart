import 'dart:async'; // new
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart'; // new
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellerplus/src/sell.dart';
import 'package:sellerplus/utils/string.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  StreamSubscription<QuerySnapshot>? _subscription;
  List<Sells> _sells = [];
  List<Sells> get getSells => _sells;

  List<Map<String, dynamic>> _topSellers = [];
  List<Map<String, dynamic>> get getTopSellers => _topSellers;

  List<Sells> _lastSells = [];
  List<Sells> get getLastSells => _lastSells;

  Map<String, dynamic> _stats = {
    'caTotal': 0,
    'productSoldTotal': 0,
    'productSoldMonth': 0,
    'caMonth': 0,
  };
  Map<String, dynamic> get getStats => _stats;

  Map<String, List<Sells>> _todoSells = {
    'late': [],
    'upcoming': [],
  };
  Map<String, List<Sells>> get getTodoSells => _todoSells;

  Map<String, Map<String, dynamic>> _userList = {};

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
        _subscription?.cancel();
      }

      FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .listen((snapshot) {
        _userList = {};
        for (var doc in snapshot.docs) {
          if (doc.data()['email'] is String) _userList[doc.id] = doc.data();
        }
      });

      _subscription = FirebaseFirestore.instance
          .collection('ventes')
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        // Reset stats
        _sells = [];
        _topSellers = [];
        _lastSells = [];
        _todoSells['late'] = [];
        _todoSells['upcoming'] = [];

        for (final document in snapshot.docs) {
          const validatedStatus = ['Vendu', 'Livré'];
          // Update stats
          _stats['caTotal'] += document.data()['price'] as int;
          _stats['productSoldTotal'] += 1;

          final date = document.data()['date'] as Timestamp;
          final now = DateTime.now();
          if (date.toDate().month == now.month) {
            _stats['productSoldMonth'] += 1;
            _stats['caMonth'] += document.data()['price'] as int;
          }

          final currentSale = Sells(
            adress: document.data()['adress'] as String,
            city: document.data()['city'] as String,
            client: capitalize(document.data()['client'] as String),
            date: date,
            idCommercial: document.data()['idCommercial'] as String,
            commercialName: _userList[document.data()['idCommercial'] as String]
                    ?["email"] ??
                'Inconnu',
            idTechnician: document.data()['idTechnician'] as String,
            technicianName: _userList[document.data()['idTechnician'] as String]
                    ?["email"] ??
                'Inconnu',
            price: document.data()['price'] as int,
            product: document.data()['product'] as String,
            statut: document.data()['statut'] as String,
          );

          // Add sells
          _sells.add(currentSale);

          // Add todo sells
          if (_loggedIn == true) {
            var statusToGet = [];

            var role = "";
            _userList.forEach((key, value) {
              if (key == user!.uid) {
                role = value['role'].toString().toLowerCase();
              }
            });

            if (role == "commercial") {
              statusToGet = ['Commandé', 'Vendu'];
            } else if (role == "technicien") {
              statusToGet = ['Vendu'];
            }

            if (statusToGet.contains(currentSale.statut)) {
              final diff = date.toDate().difference(now);
              if (diff.inDays < 0) {
                _todoSells['late']?.add(currentSale);
              } else {
                _todoSells['upcoming']?.add(currentSale);
              }
            }
          }

          // Add last sells
          if (_lastSells.length < 5 &&
              validatedStatus.contains(currentSale.statut)) {
            _lastSells.add(currentSale);
          }

          // Add top sellers
          if (document.data()['idCommercial'] == null) continue;

          final idCommercial = document.data()['idCommercial'] as String;

          String userName = _userList[idCommercial]?["email"] ?? 'Inconnu';

          var index = -1;

          for (var i = 0; i < _topSellers.length; i++) {
            if (_topSellers[i]['idCommercial'] == document.data()['idCommercial']) {
              index = i;
              break;
            }
          }

          if (index != -1) {
            _topSellers[index]['totalPrice'] += document.data()['price'];
            _topSellers[index]['productsNb'] += 1;
          } else {
            _topSellers.add({
              'commercialName': userName,
              'idCommercial': document.data()['idCommercial'],
              'totalPrice': document.data()['price'],
              'productsNb': 1,
            });
          }
        }

        notifyListeners();
      });

      notifyListeners();
    });
  }
}
