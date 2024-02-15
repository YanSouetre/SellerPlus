import 'dart:async'; // new
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart'; // new
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellerplus/src/sell.dart';

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

  Map<String, String> _userNames = {};

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
        _userNames = {};
        for (var doc in snapshot.docs) {
          if (doc.data()['email'] is String)
            _userNames[doc.id] = doc.data()['email'] as String;
        }
      });

      _subscription = FirebaseFirestore.instance
          .collection('ventes')
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        _sells = [];
        _topSellers = [];
        _lastSells = [];
        for (final document in snapshot.docs) {
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
            client: document.data()['client'] as String,
            date: date,
            idCommercial: document.data()['idCommercial'] as String,
            commercialName:
                _userNames[document.data()['idCommercial'] as String] ??
                    'Inconnu',
            idTechnician: document.data()['idTechnician'] as String,
            technicianName:
                _userNames[document.data()['idTechnician'] as String] ??
                    'Inconnu',
            price: document.data()['price'] as int,
            product: document.data()['product'] as String,
            statut: document.data()['statut'] as String,
          );

          // Add sells
          _sells.add(currentSale);

          // Add last sells
          const availableStatus = ['Vendu', 'Livré'];
          if (_lastSells.length < 5 &&
              availableStatus.contains(currentSale.statut)) {
            _lastSells.add(currentSale);
          }

          // Add top sellers
          if (document.data()['idCommercial'] == null) continue;

          final idCommercial = document.data()['idCommercial'] as String;

          String userName = _userNames[idCommercial] ?? '';

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
