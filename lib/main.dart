import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sellerplus/src/home.dart';
import 'package:sellerplus/src/profile.dart';
import 'package:sellerplus/src/sale.dart';
import 'package:sellerplus/src/sales.dart';

import 'app_state.dart';
import 'component/login.dart';
import 'component/register.dart';


void main() {
  // Modify from here...
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
  // ...to here.
}

// Add GoRouter configuration outside the App class
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Home(),
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => LoginPage(
            onSuccess: () {
              context.pushReplacement('/');
            },
          ),

          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final arguments = state.uri.queryParameters;
                return ForgotPasswordScreen(
                  email: arguments['email'],
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'register', // Ajoutez la route pour la page d'inscription
          builder: (context, state) => RegisterPage(
            onSuccess: () {
              context.pushReplacement('/');
            }),
        ),
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (context, state) {
            return ProfilePage(
              id: state.uri.queryParameters['id']
            );
          },
        ),
        GoRoute(
          path: 'sale',
          name: 'sale',
          builder: (context, state) {
            return SalePage(
              id: state.uri.queryParameters['id']
            );
          },
        ),
        GoRoute(
          path: 'sales',
          name: 'sales',
          builder: (context, state) {
            return Sales();
          },
        ),
      ],
    ),
  ],
);
// end of GoRouter configuration

// Change MaterialApp to MaterialApp.router and add the routerConfig
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Firebase Meetup',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
          highlightColor: Colors.deepPurple,
        ),
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      routerConfig: _router, // new
    );
  }
}