import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newproj/Data/useful.dart';

class ForgetPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    final theme = Theme.of(context);
    final textColor = theme.colorScheme.primary;

    Future passwordReset() async {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Password reset email sent. Check email to reset your password.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          });
      } on FirebaseAuthException catch (e) {
        print('No user found for that email.');
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text("Please ensure that you have entered a valid email."),
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

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 193, 249, 232),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          color: Color.fromARGB(255, 193, 249, 232),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                child: Container(
                  color: Color.fromARGB(255, 193, 249, 232),
                  padding: const EdgeInsets.fromLTRB(30, 130, 30, 0),
                  child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'images/forgot.png',  // Path to your image file
                        width: 300,  // Optional: set the width
                        height: 230,  // Optional: set the height
                        fit: BoxFit.cover,  // Optional: set the fit
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reset your password.", style: spaceStyle(),),
                        ],
                      ),
                    ),
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
                    SizedBox(height: 30),
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
                            print('Send Reset Email');
                            passwordReset();
                          },
                          child: Text('Send Reset Email', style: spaceStyle(fontSize: 24, color: Colors.white)),
                        ),
                        SizedBox(height: 10,),
                        ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 40, 233, 177)),
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            fixedSize: MaterialStateProperty.all(Size(270, 60)),
                            shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Back', style: spaceStyle(fontSize: 24)),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
              SizedBox(height: 120)
            ],
          ),
        ),
      ),
    );
  }
}