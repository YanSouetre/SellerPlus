import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? isLogged;

  const NavBar({super.key, this.isLogged});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
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
                  // Handle 'Dashboard' option
                  context.pushReplacement('/register');
                  // Navigate or perform any action here
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
                  // Handle 'Mes ventes' option
                  print('Mes ventes tapped');
                  // Navigate or perform any action here
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
          IconButton(
            icon: const Icon(Icons.person_pin_sharp, color: Colors.white),
            tooltip: 'Go to profile',
            onPressed: () {
              context.pushReplacement('/profile');

            },
          ),
        ],
      ),
    );
  }
}