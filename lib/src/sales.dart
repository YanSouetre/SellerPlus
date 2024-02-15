import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sellerplus/app_state.dart';
import 'package:sellerplus/component/navbar.dart';

class Sales extends StatefulWidget {
  final bool? loggedIn;

  const Sales({super.key, this.loggedIn});

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
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
                  if (!appState.loggedIn)
                    const Text('Please login to see your sales'),
                  if (appState.loggedIn)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'En retard',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          DataTable(
                            columns: const [
                              DataColumn(label: Text('Produit')),
                              DataColumn(label: Text('Client')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Statut')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: appState.getTodoSells["late"]!.map((sale) {
                              return DataRow(cells: [
                                DataCell(Text(sale.product)),
                                DataCell(Text(sale.client)),
                                DataCell(Text("${sale.date.toDate().day.toString().padLeft(2, '0')}/${sale.date.toDate().month.toString().padLeft(2, '0')}/${sale.date.toDate().year} - ${sale.date.toDate().hour.toString().padLeft(2, '0')}h${sale.date.toDate().minute.toString().padLeft(2, '0')}")),
                                DataCell(Text(sale.statut)),
                                const DataCell(Icon(Icons.file_copy_outlined)),
                              ]);
                            }).toList(),
                          ),
                          const SizedBox(height: 100),
                          Text(
                            'Aujourd\'hui - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          DataTable(
                            columns: const [
                              DataColumn(label: Text('Produit')),
                              DataColumn(label: Text('Client')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Statut')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: appState.getTodoSells["upcoming"]!
                                .map((sale) {
                              return DataRow(cells: [
                                DataCell(Text(sale.product)),
                                DataCell(Text(sale.client)),
                                DataCell(Text(
                                    "${sale.date.toDate().day.toString().padLeft(2, '0')}/${sale.date.toDate().month.toString().padLeft(2, '0')}/${sale.date.toDate().year} - ${sale.date.toDate().hour.toString().padLeft(2, '0')}h${sale.date.toDate().minute.toString().padLeft(2, '0')}")),
                                DataCell(Text(sale.statut)),
                                DataCell(IconButton(
                                  icon: const Icon(Icons.file_copy_outlined),
                                  onPressed: () {
                                    var param1 = sale.idCommercial;
                                    context.go("/sale?id=$param1");
                                  },
                                )),
                                // const DataCell(Icon(Icons.file_copy_outlined)),
                              ]);
                            }).toList(),
                          ),
                        ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
