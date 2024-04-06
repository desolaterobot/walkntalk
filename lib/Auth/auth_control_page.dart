import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './auth_page.dart';
import '../Contents/home_page.dart';

class AuthControlPage extends StatelessWidget {
  const AuthControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot)  {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}