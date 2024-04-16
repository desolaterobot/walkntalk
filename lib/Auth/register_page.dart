import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newproj/Data/useful.dart';

class RegisterPage extends StatefulWidget {

  final VoidCallback showLoginPage;
  const RegisterPage({
    super.key,
    required this.showLoginPage,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 193, 249, 232),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          color: Color.fromARGB(255, 193, 249, 232),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 40.0, 0.0, 0.0),
                    child: Text(
                      'registering for',
                      style: spaceStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'WalkNTalk',
                      style: spaceStyle(fontSize: 40),
                    ),
                  ),
                ],
              ),
              RegisterBox(showLoginPage: widget.showLoginPage),
              SizedBox(height: 80)
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterBox extends StatelessWidget {
  final VoidCallback showLoginPage;
  const RegisterBox({
    super.key,
    required this.showLoginPage,
  });
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController rePasswordController = TextEditingController();

    Future addUserDetails() async {
      await FirebaseFirestore.instance.collection('users').doc(emailController.text.trim()).set({
        'email': emailController.text.trim(),
        'username': usernameController.text.trim(),
        'totalJoined': 0,
        "topicsDiscussed" : 0,
        "friendsMade" : 0,
        "pastEvents" : [],
        "upcomingEvents" : [],
        "createdEvents" : [], 
      });
    }

    Future singUp() async {
      if (passwordController.text.trim() != rePasswordController.text.trim()) {
        print('passwords do not match');
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              title: Text('Registration Error'),
              content: Text("Passwords do not match."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          }
        );
        return;
      }
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        await addUserDetails();
      } on FirebaseAuthException catch (e) {
        print('error: $e');
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              title: Text('Registration Error'),
              content: Text("Please ensure that you have typed valid credentials."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          }
        );
      }
    }

    return Container(
      color: Color.fromARGB(255, 193, 249, 232),
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Column(
        children: [
          Center(
            child: Image.asset(
              'images/login.png',  // Path to your image file
              width: 230,  // Optional: set the width
              height: 190,  // Optional: set the height
              fit: BoxFit.cover,  // Optional: set the fit
            ),
          ),
          SizedBox(height: 10),
          TextField(
            style: spaceStyle(),
            controller: emailController,
            decoration: InputDecoration(
              labelStyle: spaceStyle(),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary)),
              labelText: 'E-mail',
            ),
            maxLines: 1,
          ),
          SizedBox(height: 15,),
          TextField(
            style: spaceStyle(),
            controller: usernameController,
            decoration: InputDecoration(
              labelStyle: spaceStyle(),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary)),
              labelText: 'Username',
            ),
            maxLines: 1,
          ),
          SizedBox(height: 15),
          TextField(
            style: spaceStyle(),
            obscureText: true,
            controller: passwordController,
            decoration: InputDecoration(
              labelStyle: spaceStyle(),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary)),
              labelText: 'Password',
            ),
            maxLines: 1,
          ),
          SizedBox(height: 15),
          TextField(
            style: spaceStyle(),
            obscureText: true,
            controller: rePasswordController,
            decoration: InputDecoration(
              labelStyle: spaceStyle(),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary)),
              labelText: 'Confirm Password',
            ),
            maxLines: 1,
          ),
          SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      fixedSize: MaterialStateProperty.all(Size(270, 60)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                    ),
                    onPressed: () {
                      // Respond to button press
                      print('request create account');
                      singUp();
                    },
                    child: Text('Create Account', style: spaceStyle(fontSize: 25, color: Colors.white)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 40, 233, 177)),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      fixedSize: MaterialStateProperty.all(Size(270, 60)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                    ),
                    onPressed: showLoginPage,
                    child: Text('Back', style: spaceStyle(fontSize: 25)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}