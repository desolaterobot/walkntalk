import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'data.dart';

//space font style
TextStyle spaceStyle({double fontSize=20, Color color = const Color.fromARGB(255, 0, 60, 46)}){
  return TextStyle(
    fontFamily: "Space", 
    fontWeight: FontWeight.bold, 
    fontSize: fontSize,
    color: color,
    height: 1.05
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
    builder: (builder)=>AlertDialog(
      title: Text(title, style: spaceStyle(fontSize: 22)),
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(body, style: spaceStyle(fontSize: 15),)
      ),
      actions: [
        TextButton(
          onPressed: ()=>closeWindow(context),
          child: Text("CLOSE", style: spaceStyle(fontSize: 20, color: Colors.red.shade400)),
        ),
      ],
    )
  );
}

//call this function in any part of your function if you want to show a warning window.
void showWarningWindow(BuildContext context, String title, String body, Function onTapOK, {double scale = 1.3, TextAlign align = TextAlign.left}){
  showDialog(
    context: context, 
    builder: (builder)=>AlertDialog(
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
          onPressed: (){onTapOK();},
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
        Text(message, style: spaceStyle(fontSize: 15),)
      ],)
      :
      const CircularProgressIndicator(),
    ),
  );
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

/////////////////////////////////////////////////////////////////////////////////////

List<Map> getEventsByIDList(List idList){
  List<Map<dynamic, dynamic>> mapList = [];
  List newIdList = idList.toSet().toList();
  for(int id in newIdList){
    for(Map<dynamic, dynamic> event in fullEventList){
      if(event["id"] == id){
        mapList.add(event);
      }
    }
  }
  return mapList;
}