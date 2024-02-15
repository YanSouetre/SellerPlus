import 'package:cloud_firestore/cloud_firestore.dart';

class Sells {
  Sells(
      {
        required this.id,
        required this.adress,
      required this.city,
      required this.client,
      required this.date,
      required this.idCommercial,
      this.commercialName,
      this.idTechnician,
      this.technicianName,
      required this.price,
      required this.product,
      required this.statut
      });

  final String id;
  final String adress;
  final String city;
  final String client;
  final Timestamp date;
  final String idCommercial;
  final String? commercialName;
  final String? idTechnician;
  final String? technicianName;
  final int price;
  final String product;
  final String statut;
}
