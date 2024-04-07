import 'package:flutter/material.dart';
import 'forget_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Data/useful.dart';

class LoginPage extends StatelessWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({
    super.key,
    required this.showRegisterPage,
  });

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
              SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 40.0, 0.0, 0.0),
                    child: Text(
                      'welcome to',
                      style: spaceStyle(fontSize: 25),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'WalkNTalk',
                      style: spaceStyle(fontSize: 40),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Start making friends...',
                      style: spaceStyle(fontSize: 23),
                    ),
                  ),
                ],
              ),
              LoginBox(showRegisterPage: showRegisterPage),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginBox extends StatelessWidget {
  final VoidCallback showRegisterPage;
  const LoginBox({
    super.key,
    required this.showRegisterPage,
  });
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    Future signIn() async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        print(e.toString());
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error Logging In'),
                content: Text("Invalid credentials. Try logging in again."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              );
            });
      }
    }

    return Material(
      child: Container(
        color: Color.fromARGB(255, 193, 249, 232),
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'images/walking.png',  // Path to your image file
                width: 300,  // Optional: set the width
                height: 200,  // Optional: set the height
                fit: BoxFit.cover,  // Optional: set the fit
              ),
            ),
            SizedBox(height: 20),
            TextField(
              style: spaceStyle(),
              controller: emailController,
              decoration: InputDecoration(
                labelStyle: spaceStyle(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.primary)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.primary)),
                labelText: 'Email',
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20),
            TextField(
              style: spaceStyle(),
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                labelStyle: spaceStyle(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.primary)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.primary)),
                labelText: 'Password',
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 40, 233, 177)),
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                        fixedSize: MaterialStateProperty.all(Size(130, 60)),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                      ),
                      onPressed: showRegisterPage,
                      child: Text('Register', style: spaceStyle(fontSize: 24)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.primary),
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                        fixedSize: MaterialStateProperty.all(Size(130, 60)),
                        shape: const MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                      onPressed: () {
                        // submit data in the text fields
                        print('request login');
                        signIn();
                        // submitLoginInfo(usernameController.text, passwordController.text);
                      },
                      child: Text('Login',
                          style: spaceStyle(fontSize: 24, color: Colors.white)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 40, 233, 177)),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    fixedSize: MaterialStateProperty.all(Size(270, 60)),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                  ),
                  onPressed: () {
                    // Respond to button press
                    print('request password retrieval');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgetPasswordPage()));
                  },
                  child:
                      Text('Forgot Password', style: spaceStyle(fontSize: 25)),
                )
              ],
            ),
            SizedBox(height: 80)
          ],
        ),
      ),
    );
  }
}
