import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sellerplus/app_state.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? isLogged;

  const NavBar({super.key, this.isLogged});



  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);



  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var appState = Provider.of<ApplicationState>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Text(
                'Seller+',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white
                ),
              )
            ],
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  context.pushReplacement('/');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  context.pushReplacement('/sales');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Mes ventes',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          if (appState.loggedIn)
            IconButton(
              icon: const Icon(Icons.person_pin, color: Colors.white),
              tooltip: 'Go to profile',
              onPressed: () {
                var param1 = _auth.currentUser?.uid;
                context.go("/profile?id=$param1");
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.contactless_outlined, color: Colors.white),
              tooltip: 'Login',
              onPressed: () {
                context.pushReplacement('/login');
              },
            ),
        ],
      ),
    );
  }
}