import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Auth/auth_control_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyDNTaCoxKF2gF2xHhuPmxrqugMS1AXQq1Y',
          appId: '1:517970202883:android:1c5fdd60e7e16e776c1936',
          messagingSenderId: '517970202883',
          projectId: 'walkntalk-79fae'));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 12, 125, 90)),
        useMaterial3: true,
      ),
      home: const AuthControlPage(),
    );
  }
}
