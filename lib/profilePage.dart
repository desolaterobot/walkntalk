import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'joinPage.dart';
import 'useful.dart';
import 'data.dart';
import 'pastEventsPage.dart';
import 'apiData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

Color cardColor = const Color.fromARGB(255, 145, 255, 202);
Color cardBorder = const Color.fromARGB(255, 0, 128, 90);
String? convoStarterString;

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  DateTime now = DateTime.now();
  Widget? convoStarters;
  //every time this page is loaded, determine if there is an event going on by looping through all the upcoming events, and checking if the current time is in between an event.
  //then, check if any of the events have already passed. if so, move them from the upcoming list to the past list

  @override
  void initState() {
    print("WINDOW INITIALIZE.");
    convoStarters = loadingSign(message: "Generating conversation starters...");
    List<String> prevTopics = [];
    List<String> currTopics = [];
    if(currentEvent != null){
      prevTopics = currentEvent!["topics"]; //fetch the prev topics (before determining the new current event).
    }
    fetchCurrentEvent();
    if(currentEvent != null){
      currTopics = currentEvent!["topics"]; //fetch the current topics.
    }
    if(!listEquals(currTopics, prevTopics)){
      print("curr:" + currTopics.toString());
      print("prev:" + prevTopics.toString());
      print("current topics is different from prev topic. calling the fetchconvostarters function.");
      fetchConvoStarters();
    }else{
      if(convoStarterString != null){
        convoStarters = Text(convoStarterString!, style: spaceStyle());
      }else{
        convoStarters = Text("obtaining from prev, but prev string is null.", style: spaceStyle());
      }
    }
    fetchWeather(); //fetch weather and put it inside the weatherReport map
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        fetchWeather();
        fetchCurrentEvent();
        setState((){});
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back,", style: spaceStyle(fontSize: 20)),
              Text("${accountDetails["username"]}",
                  style: spaceStyle(fontSize: 40)),
              statsMenu(),
              const SizedBox(height: 20),
              activityWindow(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    loadWhichEvents = 1;
                    goToEventsPage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("UPCOMING EVENTS",
                        style: spaceStyle(fontSize: 25)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    loadWhichEvents = 2;
                    goToEventsPage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text("CREATED EVENTS", style: spaceStyle(fontSize: 25)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    loadWhichEvents = 0;
                    goToEventsPage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("PAST EVENTS", style: spaceStyle(fontSize: 25)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget statsMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: (currentEvent == null)
          ? [
              const SizedBox(
                height: 10,
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Icon(Icons.sunny, size: 60),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${weatherReport['weather']}",
                        style: spaceStyle(fontSize: 23)),
                    const SizedBox(height: 2),
                    Text(
                        "${weatherReport['tempLow']}°C - ${weatherReport['tempHigh']}°C",
                        style: spaceStyle(fontSize: 17)),
                    const SizedBox(height: 2),
                    Text(
                        "Humidity: ${weatherReport['humidLow']}% - ${weatherReport['humidHigh']}%",
                        style: spaceStyle(fontSize: 13)),
                  ],
                ),
              ]),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("${accountDetails['totalJoined']}",
                      style: spaceStyle(fontSize: 90)),
                  const SizedBox(width: 20),
                  Flexible(
                      child: Text(
                    "walks with\nWalkNTalk",
                    style: spaceStyle(fontSize: 27),
                    maxLines: null,
                  )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("${accountDetails['topicsDiscussed']}",
                      style: spaceStyle(fontSize: 90)),
                  const SizedBox(width: 20),
                  Flexible(
                      child: Text(
                    "topics\ndiscussed",
                    style: spaceStyle(fontSize: 27),
                    maxLines: null,
                  )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("${accountDetails['friendsMade']}",
                      style: spaceStyle(fontSize: 90)),
                  const SizedBox(width: 20),
                  Flexible(
                      child: Text(
                    "friends\nmade",
                    style: spaceStyle(fontSize: 27),
                    maxLines: null,
                  )),
                ],
              ),
            ]
          : [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: convoStarters
              ),
            ],
    );
  }

  Widget activityWindow() {
    if (currentEvent != null) {
      //return the card
      return Column(
        children: [
          Text(
            "ONGOING ACTIVITY",
            style: spaceStyle(fontSize: 15),
          ),
          const SizedBox(height: 10),
          JoinPageState().card(
              currentEvent!,
              () => JoinPageState().showCardWindow(context, currentEvent!,
                  endEventFromButton, "LEAVE", Colors.orange)),
        ],
      );
    } else {
      String reccommend = "Loading...";
      switch (weatherReport["weather"]) {
        case "Cloudy":
          reccommend =
              "the weather is cool today...\nchill with someone today!";
          break;
        case "Thundery Showers":
          reccommend =
              "the weather isn't good today...\ndon't forget your umbrella!";
          break;
        default:
          reccommend = "the weather is great...\nwalk with someone today!";
          break;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("no events now.", style: spaceStyle(fontSize: 35)),
          const SizedBox(height: 5),
          Text(reccommend, style: spaceStyle())
        ],
      );
    }
  }

  // FUNCTIONAL EVENTS /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //check if any of the upcoming events is currently happening and dispose of any event that has passed.
  void fetchCurrentEvent(){
    List<Map> upcomingEvents =
        getEventsByIDList(accountDetails["upcomingEvents"]);
    //check if there is an event going on.
    currentEvent = null;
    for (Map event in upcomingEvents) {
      if (stringToDateTime(event["start"]).isBefore(now) &&
          stringToDateTime(event["end"]).isAfter(now)) {
        currentEvent = event;
      }
    }
    //then, check if any events have passed.
    for (Map event in upcomingEvents) {
      if (stringToDateTime(event["end"]).isBefore(now)) {
        //this event has expired.
        upcomingEvents.remove(event);
        endEvent(event);
      }
    }
  }

  Future<void> fetchConvoStarters() async {
    print("fetching convo starters...");
    if (currentEvent != null) {
      print("current event is happening. generating...");
      List<String> currentTopics = currentEvent!["topics"];
      print("GENERATING CONVO STARTERS");
      final model = GenerativeModel(model: "gemini-1.0-pro", apiKey: geminiAPIKey);
      final response = await model.generateContent([
        Content.text(
            """Given the following pool of topics: ${currentTopics}, generate ${currentTopics.length*2} conversation starter questions (whenever possible, each starter question can involve multiple topics), in bullet point form, with one space between each starter question, like this:
            
            - starter question 1

            - starter question 2

            - starter question 3

            - starter question 4

            - starter question 5
            """)
      ]);
      setState(() {
        print("generated. reloading now.");
        convoStarterString = "Here are some conversation starters you can try:\n\n${response.text}";
        convoStarters = Text(convoStarterString!, style: spaceStyle());
      });
    }
  }

  Future<void> fetchWeather() async {
    final response = await http.get(Uri.parse(weatherAPIURL));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      //print("PRINTINGGG" + data["items"].toString()); //will print out the weather text
      //print(data['items'][0]["general"]['temperature']['low']); //will print out the low temperature
      //print(data['items'][0]["general"]['temperature']['high']); //will print out the low temperature
      if (data["items"][0]["general"] != null) {
        setState(() {
          weatherReport["weather"] = data['items'][0]["general"]['forecast'];
          weatherReport["tempLow"] =
              data['items'][0]["general"]['temperature']['low'];
          weatherReport["tempHigh"] =
              data['items'][0]["general"]['temperature']['high'];
          weatherReport["humidLow"] =
              data['items'][0]["general"]['relative_humidity']['low'];
          weatherReport["humidHigh"] =
              data['items'][0]["general"]['relative_humidity']['high'];
        });
      } else {
        showSnackbar(
            context, "Unable to fetch weather information. Try again later.");
      }
    } else {
      showSnackbar(context, "Connection failed.", durationInSeconds: 3);
    }
  }

  void goToEventsPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PastEventsPage()),
    );
    if (result != null) {
      fetchCurrentEvent();
      setState(() {
        print("arrived back at profile page.");
      });
    }
  }

  void endEventFromButton(Map event) {
    if (event["author"] == accountDetails["username"]) {
      showMessageWindow(context, "Cannot leave",
          "Since you are the creator, you cannot leave this event.\n\nBut you can delete it through the CREATED EVENTS page.");
      return;
    }
    endEvent(event);
  }

  void endEvent(Map event) {
    print("Event ended: ${event["title"]}");
    accountDetails["totalJoined"]++;
    accountDetails["topicsDiscussed"] += event["topics"].length;
    accountDetails["friendsMade"] += event["currentNumOfPeople"];
    Navigator.of(context).pop();
    //TODO UPDATE THE DATABASE AFTER THIS FUNCTION(ACCOUNTDETAILS->UPCOMINGEVENTS, ACCOUNTDETAILS->PASTEVENTS) HERE!
    //upcomingEvents.remove(event);
    //pastEvents.add(event);
    accountDetails["upcomingEvents"].remove(event["id"]);
    accountDetails["pastEvents"].add(event["id"]);
    setState(() {
      if (currentEvent != null && equalMaps(event, currentEvent!)) {
        currentEvent = null;
        showSnackbar(context, "You have left ${currentEvent!["title"]}.",
            bgColor: Colors.teal);
      }
    });
  }
}
