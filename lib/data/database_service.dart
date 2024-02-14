import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot> getCollection(String collectionName) async {
    try {
      return await _firestore.collection(collectionName).get();
    } catch (e) {
      // Gérer les erreurs de récupération de la collection
      print('Erreur lors de la récupération de la collection $collectionName: $e');
      rethrow; // Renvoyer l'erreur pour la gestion en amont si nécessaire
    }
  }

// Autres méthodes pour récupérer ou mettre à jour des données Firestore
}
