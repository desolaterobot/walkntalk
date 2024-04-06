import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:newproj/Contents/home_page.dart';
import 'data.dart';

//space font style
TextStyle spaceStyle({double fontSize=20, Color color = darkerMainColor}){
  return TextStyle(
    fontFamily: "Space", 
    fontWeight: FontWeight.bold, 
    fontSize: fontSize,
    color: color,
    height: 1.06
  );
}

Color contrastAgainst(Color bg){
  return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

Color randomColor() {
  Random random = Random();
  return Color.fromRGBO(
    random.nextInt(256), // Red
    random.nextInt(256), // Green
    random.nextInt(256), // Blue
    1.0,                 // Alpha (opacity)
  );
}

//call this function in any part of your function if you want to show a message window with a single CLOSE button
void showMessageWindow(BuildContext context, String title, String body, {double scale = 1.3, TextAlign align = TextAlign.left}){
  showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text(title, style: spaceStyle(fontSize: 22)),
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(body, style: spaceStyle(fontSize: 15),)
      ),
      actions: [
        TextButton(
          onPressed: ()=>closeWindow(context),
          child: Text("OK", style: spaceStyle(fontSize: 20, color: Colors.green.shade600)),
        ),
      ],
    )
  );
}

//call this function in any part of your function if you want to show a warning window.
void showWarningWindow(BuildContext context, String title, String body, Function onTapOK, {double scale = 1.3, TextAlign align = TextAlign.left}){
  showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text(title, style: spaceStyle(fontSize: 22)),
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(body, style: spaceStyle(fontSize: 15),)
      ),
      actions: [
        TextButton(
          onPressed: ()=>closeWindow(context),
          child: Text("CANCEL", style: spaceStyle(fontSize: 20, color: Colors.red.shade400)),
        ),
        TextButton(
          onPressed: (){
            closeWindow(context);
            onTapOK();
          },
          child: Text("OK", style: spaceStyle(fontSize: 20, color: Colors.green.shade400)),
        ),
      ],
    )
  );
}

//shows a message at the bottom of the screen, along with an option to retry
void showSnackbar(BuildContext context, String message, {String? errorButton, Function? errorFunction, Color? bgColor, int durationInSeconds = 2}) {
  final snackBar = SnackBar(
    duration: Duration(seconds: durationInSeconds),
    backgroundColor: bgColor ?? Colors.red.shade400,
    content: Text(message, style: spaceStyle(color: Colors.white)),
    action: (errorButton == null) ? null : SnackBarAction(
      label: errorButton,
      onPressed: () => errorFunction!(),
    ),
  );
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

//loading sign widget
Widget loadingSign({String? message}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: message != null ? 
      Column(children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text(message, style: spaceStyle(fontSize: 15),)
      ],)
      :
      const CircularProgressIndicator(),
    ),
  );
}

bool eventClash(Map e1, Map e2){
    DateTime startOfEvent = stringToDateTime(e1["start"]);
    DateTime endOfEvent = stringToDateTime(e1["end"]);
    DateTime startTimeOfJoinedEvent = stringToDateTime(e2["start"]);
    DateTime endTimeOfJoinedEvent = stringToDateTime(e2["end"]);

    if (!(startTimeOfJoinedEvent.isBefore(startOfEvent) &&
            endTimeOfJoinedEvent.isBefore(startOfEvent) ||
        //this checks if the joined event DOES NOT CLASH. thats why there is a NOT
        startTimeOfJoinedEvent.isAfter(endOfEvent) &&
            startTimeOfJoinedEvent.isAfter(endOfEvent))) {
      //if clash, return true.
      return true;
    }
    
    return false;
}

//closes whataver popup window is open.
void closeWindow(BuildContext context){
  Navigator.of(context).pop();
}

//check if two maps are equal
bool equalMaps(Map map1, Map map2) {
  if (map1.length != map2.length) {
    print("maps are not equal length.");
    return false;
  }
  for (var key in map1.keys) {
    if (!map2.containsKey(key) || map1[key] != map2[key]) {
      print("maps do not have equal keys.");
      return false;
    }
  }
  print("maps are the same.");
  return true;
}

//STRING TO DATETIME/DATETIME TO STRING /////////////////////////////////////////////

String dateTimeToString(DateTime dateTime) {
  final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
  return formatter.format(dateTime);
}

DateTime stringToDateTime(String dateString) {
  final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
  return formatter.parse(dateString);
}

String timeAgoSinceDate(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 7) {
    return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'just now';
  }
}

String timeUntil(DateTime futureDate) {
  DateTime now = DateTime.now();
  Duration difference = futureDate.difference(now);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds} seconds away';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes away';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours away';
  } else if (difference.inDays < 30) {
    return '${difference.inDays} days away';
  } else if (difference.inDays < 365) {
    int months = now.month - futureDate.month + (12 * (now.year - futureDate.year));
    return '$months months away';
  } else {
    int years = (now.year - futureDate.year).abs();
    return '$years years away';
  }
}

// Sort a list of Event maps in chronological order.
List<Map> sortEventsChrono(List<Map> myList){
  myList.sort(
    (a,b)=>stringToDateTime(a['start']).compareTo(stringToDateTime(b['start']))
  );
  return myList;
}

 List<Map> getEventsByIDList(List idList){
   List<Map<dynamic, dynamic>> mapList = []; 
   List newIdList = idList.toSet().toList(); //remove duplicates
   print(newIdList);
   for(int id in newIdList){
     for(Map<dynamic, dynamic> event in fullEventList!){
       if(event["id"] == id){
         mapList.add(event);
       }
     }
   }
   return mapList;
 }

 Color darkenColor(Color color, {double factor = 0.4}) {
  assert(factor >= 0 && factor <= 1);

  return Color.fromARGB(
    color.alpha,
    (color.red * (1 - factor)).round(),
    (color.green * (1 - factor)).round(),
    (color.blue * (1 - factor)).round(),
  );
}