import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newproj/Contents/home_page.dart';
import 'package:newproj/Data/useful.dart';
import '../Data/database.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {

    TextEditingController usernameController = TextEditingController();
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    String userId = "";

    Future getUserName() async {
      print('getting user name');
      final user = FirebaseAuth.instance.currentUser;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user!.email!)
          .get();
      usernameController.text = userData.docs[0]['username'];
      userId = userData.docs[0].id;
    }

    Future updateUserProfile(BuildContext inContext) async {
      final user = FirebaseAuth.instance.currentUser;
      // validate before update password
      if (currentPasswordController.text.isNotEmpty && usernameController.text.isNotEmpty) {
        final credential = EmailAuthProvider.credential(email: user!.email!, password: currentPasswordController.text);
        bool flag = false;
        try {
          await user.reauthenticateWithCredential(credential);
          flag = false;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password') {
            print('The password provided is incorrect.');
            showDialog(
              context: context, 
              builder: (context) {
                return AlertDialog(
                  title: Text('Error', style: spaceStyle()),
                  content: Text("The password is incorrect.", style: spaceStyle()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK', style: spaceStyle()),
                    ),
                  ],
                );
              }
            );
            flag = true;
          } else if (e.code == 'user-mismatch') {
            print('The credentials do not match an existing user.');
            //showSnackbar(context, "The credentials do not match an existing user.");
            flag = true;
          }
        }
        print('flag: $flag');
        if (!flag) {
          print('updating profile');
          Database.showToast('Updating profile...');
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'username': usernameController.text,
          });
          showDialog(
            context: context, 
            builder: (context) {
              return AlertDialog(
                title: Text('Success', style: spaceStyle()),
                content: Text("The profile is successfully updated.", style: spaceStyle()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK', style: spaceStyle()),
                  ),
                ],
              );
            }
          );
          if (newPasswordController.text.isNotEmpty) {
            await user.updatePassword(newPasswordController.text);
          }
        }
      }
    }

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 193, 249, 232),
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Update profile", style: spaceStyle(fontSize: 30)),
              SizedBox(height: 10),
              Text("A profile update, which can be a change\nin username or password, requires\nthe current password for validation.", style: spaceStyle(fontSize: 13), textAlign: TextAlign.center,),
              SizedBox(height: 20),
              TextField(
                style: spaceStyle(),
                controller: usernameController,
                decoration: InputDecoration(
                  labelStyle: spaceStyle(fontSize: 16),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: darkerMainColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: darkerMainColor)),
                  labelText: 'Username',
                ),
                maxLines: 1,
              ),
              SizedBox(height: 15),
              TextField(
                style: spaceStyle(),
                obscureText: true,
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelStyle: spaceStyle(fontSize: 16),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: darkerMainColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: darkerMainColor)),
                  labelText: 'Current Password',
                ),
                maxLines: 1,
              ),
              SizedBox(height: 15),
              TextField(
                style: spaceStyle(),
                obscureText: true,
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelStyle: spaceStyle(fontSize: 12),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: darkerMainColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: darkerMainColor)),
                  labelText: 'New Password (empty if not changing)',
                ),
                maxLines: 1,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.teal.shade600),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  fixedSize: MaterialStateProperty.all(Size(230, 60)),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
                onPressed: () {
                  updateUserProfile(context);
                  // Navigator.pop(context);
                },
                child: Text('Update Profile', style: spaceStyle(color: Colors.white)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green.shade700),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  fixedSize: MaterialStateProperty.all(Size(230, 60)),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
                onPressed: () {
                  // Respond to button press
                  print('cancel update profile');
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: spaceStyle(color: Colors.white)),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red.shade700),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  fixedSize: MaterialStateProperty.all(Size(200, 60)),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
                onPressed: () {
                  // Respond to button press
                  print('SIGN OUT');
                  FirebaseAuth.instance.signOut();
                },
                child: Text('SIGN OUT', style: spaceStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

