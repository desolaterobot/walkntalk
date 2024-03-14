import 'package:flutter/material.dart';
import 'profilePage.dart';
import 'joinPage.dart';
import 'createPage.dart';
import 'useful.dart';

void main() {
  print("App started.");
  //if account not initialized: 
  runApp(MyApp());
}

Color mainColor = Color.fromARGB(255, 0, 224, 153);
Color lighterMainColor = Color.fromARGB(255, 195, 255, 235);
Color darkerMainColor = Color.fromARGB(255, 0, 85, 56);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  String appBarText = "My Profile";

  static final List<Widget> _widgetOptions = <Widget>[
    ProfilePage(),
    JoinPage(),
    CreatePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          appBarText = "My Profile";
          break;
        case 1:
          appBarText = "Join Activities";
          break;
        case 2:
          appBarText = "Create Page";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalkNTalk',
      home: Scaffold(
          backgroundColor: lighterMainColor,
          appBar: AppBar(
            foregroundColor: Colors.white,
            backgroundColor: mainColor,
            title: Text(appBarText, style: spaceStyle(fontSize: 26)),
          ),
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            iconSize: 30,
            unselectedItemColor: Colors.white,
            selectedItemColor: Color.fromARGB(255, 226, 255, 130),
            backgroundColor: mainColor,
            unselectedLabelStyle: spaceStyle(fontSize: 15),
            selectedLabelStyle: spaceStyle(fontSize: 18),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_walk),
                label: 'Join',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outlined),
                label: 'Create',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          ),
    );
  }
}
