import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:newproj/main.dart';
import 'package:newproj/mapPage.dart';
import 'package:newproj/useful.dart';
import 'data.dart';

const Color cardColor = Color.fromARGB(255, 145, 255, 202);
const Color cardBorder = Color.fromARGB(255, 0, 128, 90);

List<String> topicFilters = [];
//List<Map> cardList = fullCardList;
TextEditingController topicInputController = TextEditingController();
bool showEverything = false; //shows all full and past events.

class JoinPage extends StatefulWidget {
  @override
  JoinPageState createState() => JoinPageState();
}

class JoinPageState extends State<JoinPage> {
  late Widget actualCardList =
      expandedLoading(); //before the cardlist is loaded, displaay the loading sign first

  @override
  void initState() {
    loadCardListWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                                border: Border.all(color: cardBorder, width: 2),
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
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              showSelectTopicWindow(
                                  context, "Select topic filters...");
                            },
                            child: Text(
                              "CHANGE TOPIC FILTERS",
                              style: spaceStyle(fontSize: 21),
                            )),
                        ElevatedButton(
                            onPressed: () {
                              if (!showEverything)
                                showSnackbar(context,
                                    "Events are hidden either because they have ended (grey) or full (red).",
                                    bgColor: Colors.teal, durationInSeconds: 5);
                              setState(() {
                                actualCardList = expandedLoading();
                                showEverything = !showEverything;
                                loadCardListWidget();
                              });
                            },
                            child: Text(
                              showEverything
                                  ? "SHOW JOINABLE EVENTS ONLY"
                                  : "SHOW HIDDEN EVENTS",
                              style: spaceStyle(fontSize: 15),
                            )),
                      ],
                    ),
                  ),
                  actualCardList,
                ]),
          ),
        ],
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
          border: Border.all(color: cardBorder, width: 3),
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

  Future<void> loadCardListWidget() async {
    List<Map> cardList = fullEventList;
    // TODO change this to the async function that calls from the database.
    // TODO ONLY IF THE FULLCARDLIST IS NOT INITIALIZED????  IDK

    int hiddenEvents = 0;
    await Future.delayed(const Duration(
        seconds: 1)); //artificial sleep for 1 second to simulate database fetch

    //FILTERING BY TOPIC
    if (topicFilters.isNotEmpty) {
      cardList = [];
      for (Map cardInfo in fullEventList) {
        for (String topic in topicFilters) {
          if (cardInfo["topics"].contains(topic.toUpperCase())) {
            cardList.add(cardInfo);
            break;
          }
        }
      }
    } else {
      cardList = fullEventList;
    }

    //IF EVENT IS FULL, IF EVENT HAS PASSED
    List<Widget> cardWidgetList = [];
    for (Map cardInfo in cardList) {
      if (cardInfo["currentNumOfPeople"] >= cardInfo["maxNumOfPeople"]) {
        //event is full
        if (showEverything) {
          cardWidgetList.add(card(
            cardInfo,
            () => showCardWindow(context, cardInfo, (Map card) {
              showSnackbar(context, "Event is full. Join another one.");
              closeWindow(context);
            }, "FULL", Colors.red.shade400),
            background: Colors.red.shade300,
          ));
          cardWidgetList.add(const SizedBox(
            height: 10,
          ));
        }
        if (!showEverything) hiddenEvents++;
        continue;
      }

      if (DateTime.now().isAfter(stringToDateTime(cardInfo["end"]))) {
        //event is passed
        if (showEverything) {
          cardWidgetList.add(card(
            cardInfo,
            () => showCardWindow(context, cardInfo, (Map card) {
              closeWindow(context);
              showSnackbar(
                  context, "Event has already passed. Join another one.");
            }, "LAPSED", Colors.grey.shade600),
            background: Colors.grey.shade400,
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
          () => showCardWindow(
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
                  "SHOWING ${cardList.length - hiddenEvents} EVENTS",
                  style: spaceStyle(color: const Color.fromARGB(121, 0, 0, 0)),
                ),
                Text(
                  "HIDDEN ${hiddenEvents} EVENTS",
                  style: spaceStyle(color: const Color.fromARGB(121, 0, 0, 0)),
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

  Widget expandedLoading() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 600,
      ),
      child: loadingSign(),
    );
  }

  Widget tagListWidget(List<String> contents,
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

  void joinEvent(Map cardInfo) {
    //? CLASH CHECK HAS BEEN IMPLEMENTED.
    //TODO The number of people in the event should be updated in the database if successfully joined.
    DateTime startTimeOfJoinedEvent = stringToDateTime(cardInfo["start"]);
    DateTime endTimeOfJoinedEvent = stringToDateTime(cardInfo["end"]);
    List<Map> upcomingEvents =
        getEventsByIDList(accountDetails["upcomingEvents"]);

    //CHECK IF ALREADY JOINED
    for (int joinedID in accountDetails['upcomingEvents']) {
      if (joinedID == cardInfo['id']) {
        showSnackbar(context, "You have already joined ${cardInfo["title"]}.");
        closeWindow(context);
        return;
      }
    }

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
        showSnackbar(context,
            "The event you are joining clashes with ${event["title"]} by ${event["author"]}.",
            durationInSeconds: 3);
        closeWindow(context);
        return;
      }
    }

    //TODO update the database values!!!
    accountDetails["upcomingEvents"]
        .add(cardInfo["id"]); //successfully add ONLY THE ID to upcoming events.
    cardInfo[
        'currentNumOfPeople']++; //update the number of people in each event.
    //print("Event joined: ${cardInfo["title"]}");
    closeWindow(context);
    showMessageWindow(context, "Event joined!",
        "You have successfully joined ${cardInfo["title"]} by ${cardInfo["author"]}.\n\nLook for the event in the \"Upcoming Events\" section of the homepage.");
  }

  Future showCardWindow(
      BuildContext context,
      Map cardInfo,
      Function rightButtonFunction,
      String rightButtonMessage,
      Color rightButtonColor) async {
    String locationName = await MapPageState().getStreetNameFromLatLng(
        LatLng(cardInfo["location"][0][0], cardInfo["location"][0][1]));
    DateTime start = stringToDateTime(cardInfo["start"]);
    DateTime end = stringToDateTime(cardInfo["end"]);

    // ignore: use_build_context_synchronously
    return showDialog(
        context: context,
        builder: (builder) => AlertDialog(
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
                          coordinateListToBeShown = cardInfo["location"];
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapPage()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 200, 230, 230)
                            ),
                        child: Text("SHOW ON MAP",
                            style:
                                spaceStyle(fontSize: 25)),
                      ),
                    ),
                  ],
                ),
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
                          spaceStyle(fontSize: 24, color: Colors.red.shade700),
                    )),
                rightButtonMessage != ""
                    ? TextButton(
                        onPressed: () => rightButtonFunction(cardInfo),
                        child: Text(
                          rightButtonMessage,
                          style:
                              spaceStyle(fontSize: 24, color: rightButtonColor),
                        ))
                    : const SizedBox(),
              ],
            ));
  }

  TextEditingController textController = TextEditingController();
  Future showSelectTopicWindow(BuildContext context, String title) {
    textController.text = "";
    return showDialog(
        context: context,
        builder: (builder) => AlertDialog(
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
                      loadCardListWidget();
                    },
                    child: Text(
                      "CONFIRM",
                      style: spaceStyle(
                          fontSize: 22, color: Colors.green.shade700),
                    ))
              ],
            ));
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
}
