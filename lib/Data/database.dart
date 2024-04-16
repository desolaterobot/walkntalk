import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Database {
  // Retrive account details as a Map. //!IN USE
  static Future<Map<String, dynamic>> getAccountDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    late DocumentSnapshot<Map<String, dynamic>> userData;
    try{
      userData = await FirebaseFirestore.instance.collection('users').doc(user!.email).get();
    }catch(e){
      showToast(e.toString());
    }
    return userData.data() as Map<String, dynamic>;
  }

  //Retrieve the event list in the form of a list of Maps. //!IN USE
  static Future<List<Map<String, dynamic>>> getEventList() async {
    late QuerySnapshot<Map<String, dynamic>> eventList;
    try{
      eventList =
        await FirebaseFirestore.instance.collection('events').get();
    }catch(e){
      showToast(e.toString());
    }
    return eventList.docs.map((e) => e.data()).toList();
  }

  // Updates the databse after joining (may be able to be placed within joinEvent) //!IN USE
  static Future<void> updateDatabaseOnJoin(dynamic newEvents, dynamic cardDetails) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(cardDetails['id'].toString())
          .update({
        'currentNumOfPeople': FieldValue.increment(1),
      });
    } catch (e) {
      showToast(e.toString());
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email!)
          .update({
        'upcomingEvents': newEvents,
      });
    } catch (e) {
      showToast(e.toString());
    }
  }

  // When the user leaves an event, update the database of events, and also the user statistics. //!IN USE
  static Future<void> updateDatabaseOnLeave(dynamic newEvents, dynamic cardId) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(cardId.toString())
          .update({
        'currentNumOfPeople': FieldValue.increment(-1),
      });
    } catch (e) {
      showToast(e.toString());
      return;
    }
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email!)
          .update({
        'upcomingEvents': newEvents,
      });
    } catch (e) {
      showToast(e.toString());
    }
  }

  //appends an event to the database. //!IN USE
  static Future<void> addEvent(Map<String, dynamic> event) async {
    List<List<double>> coordinateList = event['location'];
    event['location'] = [];
    for (List<double> coor in coordinateList) {
      event['location'].add(GeoPoint(coor[0], coor[1]));
    }
    await FirebaseFirestore.instance
        .collection('events')
        .doc(event['id'].toString())
        .set(event)
        .then((value) => print("Event Added: ${event['id']}"))
        .catchError((error) => showToast(error.toString()));
  }

  //takes the global accountDetails Map, and updates the database with it. //!IN USE
  static Future<void> updateAccountDetails(Map accountDetails) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email!)
        .update({
      'upcomingEvents': accountDetails['upcomingEvents'],
      'pastEvents': accountDetails['pastEvents'],
      'createdEvents': accountDetails['createdEvents'],
      'totalJoined': accountDetails['totalJoined'],
      'topicsDiscussed': accountDetails['topicsDiscussed'],
      'friendsMade': accountDetails['friendsMade'],
    }).then((value) {
      print("User updated successfully");
    }).catchError((error) {
      showToast(error.toString());
    });
  }

  // WHEN DELETING A EVENT, REMOVE THE EVENT FROM THE DATABASE. //!IN USE
  static Future<void> updateDatabaseOnDelete(int eventID, Map newAccountDetails) async {
      try {
        await FirebaseFirestore.instance.collection('events').doc(eventID.toString()).delete();
        print('Document deleted successfully');
      } catch (e) {
        print(showToast(e.toString()));
      }
      
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email!)
          .update({
        'upcomingEvents': newAccountDetails['upcomingEvents'],
        'createdEvents': newAccountDetails['createdEvents'],
      }).then((value) {
        print("User updated successfully");
      }).catchError((error) {
        showToast(error.toString());
      });
  }

    // Commit changes to database.
  static Future<void> updateDatabaseOnEventEnd(dynamic newUserData, Map? onGoingEvent) async {
    final user = FirebaseAuth.instance.currentUser;
    //update user details
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.email!)
          .update({
        'upcomingEvents': newUserData['upcomingEvents'],
        'pastEvents': newUserData['pastEvents'],
        'totalJoined': newUserData['totalJoined'],
        'topicsDiscussed': newUserData['topicsDiscussed'],
        'friendsMade': newUserData['friendsMade'],
      });
    } catch (e) {
      showToast(e.toString());
    }
    //update event details (if still ongoing)
    if(onGoingEvent != null){
      try {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(onGoingEvent['id'].toString())
            .update({
          'currentNumOfPeople': FieldValue.increment(1),
        });
      } catch (e) {
        showToast(e.toString());
        return;
      } 
    }
  }

  // Increment to make sure the ID taken 
  static Future<void> incrementGlobalID() async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc("0")
          .update({
        'currentNumOfPeople' : FieldValue.increment(1),
      });
    } catch (e) {
      showToast(e.toString());
      return;
    } 
  }

  //show a small message at the bottom of the screen. used because it does not require context hehe
  static showToast(String message){
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 16.0, // Customize font size
    );
  }
}
