import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:newproj/Contents/map_page.dart';
import 'package:newproj/Data/useful.dart';
import '../Data/data.dart';
import 'dart:math';
import 'package:location/location.dart';
import '../Data/database.dart';

const Color cardColor = Color.fromARGB(255, 145, 255, 202);
const Color cardBorder = Color.fromARGB(255, 0, 128, 90);

List<String> topicFilters = [];
GeoPoint? currentLocation;
TextEditingController topicInputController = TextEditingController();
bool showEverything = false; //shows all full and past events.

class JoinPage extends StatefulWidget {
  @override
  JoinPageState createState() => JoinPageState();
}

class JoinPageState extends State<JoinPage> {
  late Widget actualCardList =
      expandedLoading(); //before the cardlist is loaded, displaay the loading sign first
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    retrieveAvailableEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          actualCardList = expandedLoading();
        });
        currentLocation = null;
        retrieveAvailableEvents();
        print("REFRESHING LIST");
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: topicFilters.isEmpty
                          ? Text("NO FILTERS SELECTED", style: spaceStyle())
                          : Container(
                              decoration: BoxDecoration(
                                  color: cardColor,
                                  border:
                                      Border.all(color: cardBorder, width: 2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text("SHOWING EVENTS WITH TOPIC:",
                                      style: spaceStyle(fontSize: 15)),
                                  const SizedBox(height: 10),
                                  tagListWidget(topicFilters),
                                ],
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.blue.shade200),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(10)),
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)))),
                                ),
                                onPressed: () {
                                  filterByTopic(
                                      context, "Select topic filters...");
                                },
                                child: Text(
                                  "FILTER TOPICS",
                                  style: spaceStyle(fontSize: 15),
                                )),
                            const SizedBox(width: 5),
                            ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.lightGreen.shade400),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(10)),
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)))),
                                ),
                                onPressed: () {
                                  if (!showEverything)
                                    showSnackbar(context,
                                        "Events that not joinable are now being shown.",
                                        bgColor: Colors.teal,
                                        durationInSeconds: 5);
                                  setState(() {
                                    actualCardList = expandedLoading();
                                    showEverything = !showEverything;
                                    retrieveAvailableEvents();
                                  });
                                },
                                child: Text(
                                  showEverything
                                      ? "SHOW JOINABLE\nEVENTS ONLY"
                                      : "SHOW ALL EVENTS",
                                  style: spaceStyle(
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ],
                        ),
                      ),
                    ),
                    actualCardList,
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget card(Map cardInfo, Function cardTapFunction,
      {Color background = cardColor}) {
    DateTime startDate = stringToDateTime(cardInfo["start"]);
    return InkWell(
      onTap: () {
        cardTapFunction();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: background == cardColor ? cardBorder: darkenColor(background), width: 3),
          color: background,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cardInfo["title"], style: spaceStyle(fontSize: 20)),
                    const SizedBox(height: 5),
                    Text("organized by ${cardInfo['author']}",
                        style: spaceStyle(fontSize: 13)),
                    const SizedBox(height: 10),
                    Text(
                        "${startDate.day}/${startDate.month}/${startDate.year} ${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}",
                        style: spaceStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    tagListWidget(cardInfo["topics"]),
                  ],
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 30),
                child: Column(
                  children: [
                    const Icon(Icons.directions_walk, size: 30),
                    Text(
                      cardInfo["type"],
                      style: spaceStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget expandedLoading() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 600,
      ),
      child: loadingSign(),
    );
  }

  Widget tagListWidget(List<dynamic> contents,
      {double fontSize = 13, WrapAlignment wrapAlign = WrapAlignment.start}) {
    List<Widget> tagList = [];
    for (String tag in contents) {
      Color tagColor = getColorFromTopic(tag);
      tagList.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
          color: tagColor, // Container color
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Text(tag,
              style: spaceStyle(fontSize: fontSize, color: Colors.black)),
        ),
      ));
      tagList.add(SizedBox(width: 5));
    }
    return Wrap(
      alignment: wrapAlign,
      runSpacing: 5,
      children: tagList,
    );
  }

  Widget joinPageTopicListWindow() {
    List<String> contents = [];
    for (var entry in topicsToColors.entries) {
      for (var topic in entry.key) {
        contents.add(topic.toUpperCase());
      }
    }
    List<Widget> tagList = [];
    for (String tag in contents) {
      Color tagColor = getColorFromTopic(tag);
      tagList.add(InkWell(
        onTap: () {
          textController.text = "${textController.text}$tag, ";
          textController.selection = TextSelection.fromPosition(
            TextPosition(offset: textController.text.length),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(5), // Adjust the radius as needed
            color: tagColor, // Container color
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child:
                Text(tag, style: spaceStyle(fontSize: 20, color: Colors.black)),
          ),
        ),
      ));
      tagList.add(SizedBox(width: 5));
    }
    return Wrap(
      runSpacing: 5,
      children: tagList,
    );
  }

  //FUNCTIONAL METHODS//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // Distance in km between two coordinates using Haversine formula (accurate but much slower).
  double calculateDistance(GeoPoint c1, GeoPoint c2) {
    //Convert latitude and longitude from degrees to radians
    final lat1Rad = c1.latitude * (pi / 180);
    final lon1Rad = c1.longitude * (pi / 180);
    final lat2Rad = c2.latitude * (pi / 180);
    final lon2Rad = c2.longitude * (pi / 180);

    //Haversine formula
    final deltaLat = lat2Rad - lat1Rad;
    final deltaLon = lon2Rad - lon1Rad;
    final a = pow(sin(deltaLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(deltaLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    const radiusEarthKm = 6371.0;
    final distance = radiusEarthKm * c;
    return distance;
  }

  // Distance in coordinate units between two coordinates using Pythagoras formula (inaccurate but fast).
  double fastCalculateDistance(GeoPoint c1, GeoPoint c2) {
    final dx = c2.latitude - c1.latitude;
    final dy = c2.longitude - c1.longitude;
    return sqrt(dx * dx + dy * dy);
  }

  // Sort a list of events by increasing distance from user.
  List<Map> sortEventsByDistance(List<Map> events, GeoPoint myLocation) {
    print("sorting events...");
    events.sort((a, b) => fastCalculateDistance(myLocation, a['location'][0])
        .compareTo(fastCalculateDistance(myLocation, b['location'][0])));
    return events;
  }

  // Async function that sets the currentLocation global variable.
  Future<void> getLocation() async {
    Location location = Location();
    late LocationData locationData;
    print("GETTING CURRENT LOCATION");
    try {
      locationData = await location.getLocation();
    } catch (e) {
      showSnackbar(context, "No access to location.");
      return null;
    }
    print(
        "GOT CURRENT LOCATION ${locationData.latitude}, ${locationData.longitude}");
    currentLocation = GeoPoint(locationData.latitude!, locationData.longitude!);
  }

  // Load the event data, then show them all as a list of cards.
  Future<void> retrieveAvailableEvents() async {
    if(currentLocation == null){
      await getLocation();
    }
    // get necessary data
    accountDetails = await Database.getAccountDetails();
    fullEventList = await Database.getEventList();
    fullEventList!.removeAt(0); //remove the first element, which is the GLOBAL VARS

    List<Map> cardList = [];

    if (currentLocation != null) {
      fullEventList = sortEventsByDistance(fullEventList!, currentLocation!);
    } else {
      showSnackbar(context, "No location found.");
      return;
    }

    int hiddenEvents = 0;

    //FILTERING BY TOPIC
    if (topicFilters.isNotEmpty) {
      cardList = [];
      for (Map cardInfo in fullEventList!) {
        for (String topic in topicFilters) {
          if (cardInfo["topics"].contains(topic.toUpperCase())) {
            cardList.add(cardInfo);
            break;
          }
        }
      }
    } else {
      cardList = fullEventList!;
    }

    //EVENT IS FULL
    List<Widget> cardWidgetList = [];
    for (Map cardInfo in cardList) {
      if (cardInfo["currentNumOfPeople"] >= cardInfo["maxNumOfPeople"]) {
        //event is full
        if (showEverything) {
          cardWidgetList.add(card(
            cardInfo,
            () => showEventInfo(context, cardInfo,
                (Map card, BuildContext contextIn) {
              //showMessageWindow(context, "Unable to join event.", "This event is full.");
              closeWindow(contextIn);
              showSnackbar(context, "This event is full.");
            }, "FULL", Colors.red.shade400),
            background: Colors.red.shade200,
          ));
          cardWidgetList.add(const SizedBox(
            height: 10,
          ));
        }
        if (!showEverything) hiddenEvents++;
        continue;
      }

      //EVENT HAS ALREADY ENDED
      if (DateTime.now().isAfter(stringToDateTime(cardInfo["end"]))) {
        //event is passed
        if (showEverything) {
          cardWidgetList.add(card(
            cardInfo,
            () => showEventInfo(context, cardInfo,
                (Map card, BuildContext contextIn) {
              closeWindow(contextIn);
              showSnackbar(context,
                  "This event has ended ${timeAgoSinceDate(stringToDateTime(cardInfo["end"]))}.");
            }, "LAPSED", Colors.grey.shade600),
            background: Colors.grey.shade200,
          ));
          cardWidgetList.add(const SizedBox(
            height: 10,
          ));
        }
        if (!showEverything) hiddenEvents++;
        continue;
      }

      //YOU CREATED IT
      if (accountDetails!['createdEvents'].contains(cardInfo["id"])) {
        //event is created by user.
        if (showEverything) {
          cardWidgetList.add(card(
            cardInfo,
            () => showEventInfo(context, cardInfo,
                (Map card, BuildContext contextIn) {
              closeWindow(contextIn);
              showSnackbar(context,
                  "You created this event, so you have already joined it.");
            }, "JOINED", Colors.blue.shade600),
            background: Colors.blue.shade200,
          ));
          cardWidgetList.add(const SizedBox(
            height: 10,
          ));
        }
        if (!showEverything) hiddenEvents++;
        continue;
      }

      //YOU ALREADY JOINED THIS EVENT
      if (accountDetails!['upcomingEvents'].contains(cardInfo["id"])) {
        //event is created by user.
        if (showEverything) {
          cardWidgetList.add(card(
            cardInfo,
            () => showEventInfo(context, cardInfo,
                (Map card, BuildContext contextIn) {
              closeWindow(contextIn);
              showSnackbar(context, "You have already joined this event.");
            }, "JOINED", Colors.orange.shade600),
            background: Colors.orange.shade200,
          ));
          cardWidgetList.add(const SizedBox(
            height: 10,
          ));
        }
        if (!showEverything) hiddenEvents++;
        continue;
      }

      //EVENT IS CLASHING WITH ANOTHER EVENT THAT WE HAVE JOINED.
      if (eventClash(accountDetails!, cardInfo).isNotEmpty){
        //event is passed
        if (showEverything) {
          cardWidgetList.add(card(
            cardInfo,
            () => showEventInfo(context, cardInfo,
                (Map card, BuildContext contextIn) {
              closeWindow(contextIn);
              showSnackbar(context, "This event clashes with ${eventClash(accountDetails!, cardInfo)['title']}");
            }, "CLASH", Colors.purple.shade600),
            background: Colors.purple.shade200,
          ));
          cardWidgetList.add(const SizedBox(
            height: 10,
          ));
        }
        if (!showEverything) hiddenEvents++;
        continue;
      }

      //this is a joinable event
      cardWidgetList.add(card(
          cardInfo,
          () => showEventInfo(
              context, cardInfo, joinEvent, "JOIN", Colors.green.shade600)));
      cardWidgetList.add(const SizedBox(
        height: 10,
      ));
    }

    //by this point the loading of the card list is done.
    if (!mounted) return;
    setState(() {
      actualCardList = Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "SHOWING NEAREST ${cardList.length - hiddenEvents} EVENTS",
                  style: spaceStyle(color: const Color.fromARGB(121, 0, 0, 0)),
                ),
                Text(
                  "HIDDEN ${hiddenEvents} EVENTS",
                  style: spaceStyle(
                      color: const Color.fromARGB(121, 0, 0, 0), fontSize: 15),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 600,
            ),
            child: Column(
              children: cardWidgetList,
            ),
          ),
        ],
      );
    });
  }

  // Fetch events from an list of event ID's, used within joinEvent to implement clash checking.
  List<Map> getEventsByIDList(List idList) {
    List<Map<dynamic, dynamic>> mapList = [];
    List newIdList = idList.toSet().toList();
    for (int id in newIdList) {
      for (Map<dynamic, dynamic> event in fullEventList!) {
        if (event["id"] == id) {
          mapList.add(event);
        }
      }
    }
    return mapList;
  }

  // Show the topic selection window to select topics to filter.
  void filterByTopic(BuildContext context, String title) {
    textController.text = "";
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: spaceStyle(fontSize: 20)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    maxLines: null,
                    controller: textController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      hintText: "Topics seperated by commas...",
                      filled: true,
                      fillColor: Colors.green.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 43, 128, 48),
                          width: 1,
                        ),
                      ),
                    ),
                    style: spaceStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Center(
                      child: Text(
                          "Tap to select a topic, or add a custom topic yourself in the above text field.",
                          textAlign: TextAlign.center,
                          style: spaceStyle(fontSize: 14))),
                  const SizedBox(height: 20),
                  SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: joinPageTopicListWindow())),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                    onPressed: () {
                      closeWindow(context);
                    },
                    child: Text(
                      "CLOSE",
                      style:
                          spaceStyle(fontSize: 22, color: Colors.red.shade700),
                    )),
                TextButton(
                    onPressed: () {
                      closeWindow(context);
                      actualCardList = expandedLoading();
                      setState(() {
                        topicFilters = textController.text
                            .split(",")
                            .map((e) => e.trim().toUpperCase())
                            .toList();
                        topicFilters = topicFilters.toSet().toList();
                        if (topicFilters.contains("")) {
                          topicFilters.remove("");
                        }
                        if (topicFilters.isNotEmpty && topicFilters[0] == "") {
                          topicFilters = [];
                        }
                      });
                      retrieveAvailableEvents();
                    },
                    child: Text(
                      "CONFIRM",
                      style: spaceStyle(
                          fontSize: 22, color: Colors.green.shade700),
                    ))
              ],
            ));
  }

  // Show the informational window every time a card is tapped.
  Future showEventInfo(
      BuildContext context,
      Map cardInfo,
      Function rightButtonFunction,
      String rightButtonMessage,
      Color rightButtonColor) async {
    String locationName = await MapPageState().getStreetNameFromLatLng(LatLng(
        cardInfo["location"][0].latitude, cardInfo["location"][0].longitude));
    DateTime start = stringToDateTime(cardInfo["start"]);
    DateTime end = stringToDateTime(cardInfo["end"]);

    // ignore: use_build_context_synchronously
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cardInfo["title"], style: spaceStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text("organized by ${cardInfo["author"]}",
                      style: spaceStyle(fontSize: 15)),
                ],
              ),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded),
                        const SizedBox(width: 4),
                        Flexible(
                            child: Text("ID: ${cardInfo['id']}",
                                style: spaceStyle(fontSize: 15))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 4),
                        Flexible(
                            child: Text(locationName,
                                style: spaceStyle(fontSize: 15))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk_rounded),
                        const SizedBox(width: 4),
                        Flexible(
                            child: Text(
                                "${cardInfo["currentNumOfPeople"]}/${cardInfo["maxNumOfPeople"]} people",
                                style: spaceStyle(fontSize: 15))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 4),
                        Flexible(
                            child: Text(
                                "${start.day}/${start.month}/${start.year}",
                                style: spaceStyle(fontSize: 15))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined),
                        const SizedBox(width: 4),
                        Flexible(
                            child: Text(
                                "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} to ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}",
                                style: spaceStyle(fontSize: 15))),
                      ],
                    ),
                    const Divider(
                        color: Color.fromARGB(28, 0, 0, 0),
                        height: 25,
                        thickness: 1.5),
                    Text(
                        cardInfo["description"] == ""
                            ? "No description provided."
                            : cardInfo["description"],
                        maxLines: null,
                        style: spaceStyle(fontSize: 15)),
                    const Divider(
                        color: Color.fromARGB(28, 0, 0, 0),
                        height: 25,
                        thickness: 1.5),
                    Text("TOPICS", style: spaceStyle(fontSize: 25)),
                    const SizedBox(height: 10),
                    tagListWidget(cardInfo["topics"]),
                    const Divider(
                        color: Color.fromARGB(28, 0, 0, 0),
                        height: 25,
                        thickness: 1.5),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          isSelectingPath = false;
                          coordinateListToBeShown = cardInfo["location"]
                              .map((geo) => [geo.latitude, geo.longitude])
                              .toList();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapPage()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 200, 230, 230)),
                        child: Text("SHOW ON MAP",
                            style: spaceStyle(fontSize: 25)),
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                    onPressed: () => closeWindow(context),
                    child: Text(
                      "CLOSE",
                      style:
                          spaceStyle(fontSize: 24, color: Colors.red.shade700),
                    )),
                rightButtonMessage != ""
                    ? TextButton(
                        onPressed: () => rightButtonFunction(cardInfo, context),
                        child: Text(
                          rightButtonMessage,
                          style:
                              spaceStyle(fontSize: 24, color: rightButtonColor),
                        ))
                    : const SizedBox(),
              ],
            ));
  }

  // Lets the user join the event.
  Future<void> joinEvent(Map cardInfo, BuildContext contextIn) async {
    showSnackbar(contextIn, "Joining...", durationInSeconds: 2, bgColor: Colors.teal);
    closeWindow(contextIn);

    //? fetch account details a final time, just in case?
    accountDetails = await Database.getAccountDetails();

    accountDetails!["upcomingEvents"]
        .add(cardInfo["id"]); //successfully add ONLY THE ID to upcoming events.
    await Database.updateDatabaseOnJoin(
        accountDetails!['upcomingEvents'], cardInfo);
    showMessageWindow(context, "Event joined!",
        "You have successfully joined ${cardInfo["title"]} by ${cardInfo["author"]}.\n\nLook for the event in the \"Upcoming Events\" section of the homepage.");

    //REFRESH IN THE END.
    setState(() {
      actualCardList = expandedLoading();
    });
    currentLocation = null;
    retrieveAvailableEvents();
    print("REFRESHING LIST");
  }

  //returns AN EMPTY MAP if the given event DOES NOT CLASH WITH ANYTHING
  Map eventClash(Map accountDetails, Map cardInfo){
    DateTime startTimeOfJoinedEvent = stringToDateTime(cardInfo["start"]);
    DateTime endTimeOfJoinedEvent = stringToDateTime(cardInfo["end"]);
    List<Map> upcomingEvents =
        getEventsByIDList(accountDetails["upcomingEvents"]);

    //CHECK FOR CLASH
    for (Map event in upcomingEvents) {
      DateTime startOfEvent = stringToDateTime(event["start"]);
      DateTime endOfEvent = stringToDateTime(event["end"]);

      //for every event in upcomingEvents, must check if that event clashes with the event to be joined.
      if (!(startTimeOfJoinedEvent.isBefore(startOfEvent) &&
              endTimeOfJoinedEvent.isBefore(startOfEvent) ||
          //this checks if the joined event DOES NOT CLASH. thats why there is a NOT
          startTimeOfJoinedEvent.isAfter(endOfEvent) &&
              startTimeOfJoinedEvent.isAfter(endOfEvent))) {
        //if clash, do not join.
        return event;
      }
    }
    return {};
  }
}
