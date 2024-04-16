import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:newproj/Contents/home_page.dart';
import 'package:newproj/Data/data.dart';
import 'join_page.dart';
import '../Data/useful.dart';
import 'past_events_page.dart';
import '../Data/apiData.dart';
import '../Auth/update_profile_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../Data/database.dart';

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
  Map? currentEvent;
  Map weatherReport = {
    "weather": "Loading weather...",
    "tempLow": 0,
    "tempHigh": 0,
    "humidLow": 0,
    "humidHigh": 0,
  };

  //every time this page is loaded, determine if there is an event going on by looping through all the upcoming events, and checking if the current time is in between an event.
  //then, check if any of the events have already passed. if so, move them from the upcoming list to the past list

  Future<void> loadProfile() async {
    accountDetails = await Database.getAccountDetails();
    fullEventList = await Database.getEventList();

    convoStarters = loadingSign(message: "Generating conversation starters...");
    List<dynamic> prevTopics = [];
    List<dynamic> currTopics = [];
    if (currentEvent != null) {
      prevTopics = currentEvent![
          "topics"]; //fetch the prev topics (before determining the new current event).
    }
    fetchCurrentEvent();
    if (currentEvent != null) {
      currTopics = currentEvent!["topics"]; //fetch the current topics.
    }
    if (!listEquals(currTopics, prevTopics)) {
      print("curr:" + currTopics.toString());
      print("prev:" + prevTopics.toString());
      print(
          "current topics is different from prev topic. calling the fetchconvostarters function.");
      fetchConvoStarters();
    } else {
      if (convoStarterString != null) {
        convoStarters = convoWidgetBuilder(convoStarterString!);
      } else {
        convoStarters = Text("obtaining from prev, but prev string is null.",
            style: spaceStyle());
      }
    }
    await fetchWeather(); //fetch weather and put it inside the weatherReport map
  }

  @override
  void initState() {
    loadProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        //convoStarters = loadingSign(message: "Generating conversation starters...");
        fetchWeather();
        loadProfile();
        fetchCurrentEvent();
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          accountDetails == null
                              ? "Fetching data..."
                              : "Welcome back,",
                          style: spaceStyle(fontSize: 20)),
                      Text(
                          accountDetails == null
                              ? "Loading..."
                              : "${accountDetails!["username"]}",
                          style: spaceStyle(fontSize: 40)),
                    ],
                  ),
                  Expanded(child: SizedBox()),
                  IconButton(
                      onPressed: goToUpdateProfile,
                      icon: Icon(Icons.settings),
                      iconSize: 40,
                      color: darkerMainColor),
                ],
              ),
              statsMenu(),
              const SizedBox(height: 10),
              activityWindow(),
              Divider(
                  color: Color.fromARGB(65, 0, 126, 72),
                  height: 40,
                  indent: 20,
                  endIndent: 20,
                  thickness: 2),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.green.shade300),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    fixedSize: MaterialStateProperty.all(Size(340, 70)),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                  ),
                  onPressed: () {
                    loadWhichEvents = 1;
                    goToEventsPage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        const Icon(Icons.event, color: Colors.black87, size: 40),
                        SizedBox(width: 10),
                        Text(
                          "UPCOMING EVENTS",
                          style: spaceStyle(fontSize: 25, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blue.shade300),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    fixedSize: MaterialStateProperty.all(Size(340, 70)),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                  ),
                  onPressed: () {
                    loadWhichEvents = 2;
                    goToEventsPage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_calendar_rounded,
                            color: Colors.black87, size: 40),
                        SizedBox(width: 10),
                        Text(
                          "CREATED EVENTS",
                          style: spaceStyle(fontSize: 25, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.orange.shade300),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    fixedSize: MaterialStateProperty.all(Size(340, 70)),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                  ),
                  onPressed: () {
                    loadWhichEvents = 0;
                    goToEventsPage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_off_outlined,
                            color: Colors.black87, size: 40),
                        SizedBox(width: 10),
                        Text(
                          "PAST EVENTS",
                          style: spaceStyle(fontSize: 25, color: Colors.black87),
                        ),
                      ],
                    ),
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
                height: 20,
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Icon(Icons.sunny, size: 80, color: darkerMainColor),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${weatherReport['weather']}",
                        style: spaceStyle(fontSize: 23)),
                    const SizedBox(height: 2),
                    Text(
                        "${weatherReport['tempLow']}°C - ${weatherReport['tempHigh']}°C",
                        style: spaceStyle(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(
                        "Humidity: ${weatherReport['humidLow']}% - ${weatherReport['humidHigh']}%",
                        style: spaceStyle(fontSize: 15)),
                  ],
                ),
              ]),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      accountDetails == null
                          ? "??"
                          : "${accountDetails!['totalJoined']}",
                      style: spaceStyle(fontSize: 70)),
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
                  Text(
                      accountDetails == null
                          ? "??"
                          : "${accountDetails!['topicsDiscussed']}",
                      style: spaceStyle(fontSize: 70)),
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
                  Text(
                      accountDetails == null
                          ? "??"
                          : "${accountDetails!['friendsMade']}",
                      style: spaceStyle(fontSize: 70)),
                  const SizedBox(width: 20),
                  Flexible(
                      child: Text(
                    "human\ninteractions",
                    style: spaceStyle(fontSize: 27),
                    maxLines: null,
                  )),
                ],
              ),
              const SizedBox(height: 10),
            ]
          : [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: convoStarters),
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
              () => JoinPageState().showEventInfo(
                  context, currentEvent!, leaveEvent, "LEAVE", Colors.orange)),
        ],
      );
    } else {
      String reccommend = "Loading...";
      if(accountDetails != null){
        if(accountDetails!['upcomingEvents'].isNotEmpty){
          reccommend = "but your next event, ${sortEventsChrono(getEventsByIDList((accountDetails!['upcomingEvents'])))[0]['title']} is only ${timeUntil(stringToDateTime(sortEventsChrono(getEventsByIDList((accountDetails!['upcomingEvents'])))[0]['start']))}!";
        }else{
          switch (weatherReport["weather"]) {
            case "Cloudy":
              reccommend =
                  "the weather is cool...\nchill with someone today!";
              break;
            case "Thundery Showers":
              reccommend =
                  "the weather isn't good today...\ndon't forget your umbrella!";
              break;
            default:
              reccommend = "the weather is great...\nwalk with someone today!";
              break;
          }
        }
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

  // Check if any of the upcoming events is currently happening and dispose of any event that has passed.
  void fetchCurrentEvent() {
    List<Map> upcomingEvents =
        getEventsByIDList(accountDetails!["upcomingEvents"]);
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
        endEvent(event, false); //! calling endEvent with the flag to FALSE would mean to dispose of any expired events, then update database.
      }
    }
  }

  // Get events from a list of event ID's.
  List<Map> getEventsByIDList(List idList) {
    List<Map<dynamic, dynamic>> mapList = [];
    List newIdList = idList.toSet().toList();
    print(newIdList);
    for (int id in newIdList) {
      for (Map<dynamic, dynamic> event in fullEventList!) {
        if (event["id"] == id) {
          mapList.add(event);
        }
      }
    }
    return mapList;
  }

  // Calls the Gemini API to ask for conversation starter sentences given the topics on the current event.
  Future<void> fetchConvoStarters() async {
    print("fetching convo starters...");
    if (currentEvent != null) {
      print("current event is happening. generating...");
      List<dynamic> currentTopics = currentEvent!["topics"];
      print("GENERATING CONVO STARTERS");
      final model =
          GenerativeModel(model: "gemini-1.0-pro", apiKey: geminiAPIKey);
      final response = await model.generateContent([
        Content.text(
            """Given the following pool of topics: ${currentTopics}, generate 7 unnumbered conversation starter questions (whenever possible, each starter question can involve multiple topics).
            Display the questions in one long string with each question seperated by only a hashtag (#).
            """)
      ]);
      if (mounted) {
        setState(() {
          print("generated. reloading now.");
          convoStarterString = "${response.text}";
          convoStarters = convoWidgetBuilder(convoStarterString!);
        });
      }
    }
  }

  // Calls the NEA weather API for weather information.
  Future<void> fetchWeather() async {
    late dynamic response;
    try{
      response = await http.get(Uri.parse(weatherAPIURL));
    }catch(e){
      Database.showToast("Could not fetch weather information.");
      return;
    }
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      //print("PRINTINGGG" + data["items"].toString()); //will print out the weather text
      //print(data['items'][0]["general"]['temperature']['low']); //will print out the low temperature
      //print(data['items'][0]["general"]['temperature']['high']); //will print out the low temperature
      if (data["items"][0]["general"] != null) {
        if (mounted) {
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
        }
      } else {
        showSnackbar(
            context, "Unable to fetch weather information. Try again later.");
      }
    } else {
      showSnackbar(context, "Connection failed.", durationInSeconds: 3);
    }
  }

  // Displays the events page on the navigator.
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

  // Displays the update profile page.
  void goToUpdateProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateProfilePage()),
    );
    if (result != null) {
      setState(() {
        print("arrived back at profile page.");
      });
    }
  }

  // Manually leave the event WHEN EVENT IS ONGOING!!! (leaving the event through the profile page)
  void leaveEvent(Map event, BuildContext contextIn) {
    if (accountDetails!['createdEvents'].contains(event['id'])) {
      closeWindow(contextIn);
      showMessageWindow(context, "Cannot leave",
          "Since you are the creator, you cannot leave this event.\n\nBut you can delete it through the CREATED EVENTS page.");
      return;
    }
    closeWindow(contextIn);
    endEvent(event, true);
  }

  // When the event has ended, update the user account information and also event list. (very messy)
  void endEvent(Map event, bool isOngoing) async {
    if (isOngoing) {
      //! if this event is not included in past events (means that it has not been joined/ended before) then update stats.
      //! this is because stats may duplicate if a person joins more than once.
      accountDetails!["upcomingEvents"].remove(event["id"]);
      event["currentNumOfPeople"]--;
      if(!accountDetails!['pastEvents'].contains(event['id'])){
        accountDetails!["totalJoined"]++;
        accountDetails!["topicsDiscussed"] += event["topics"].length;
        accountDetails!["friendsMade"] += (event["currentNumOfPeople"]-1); //!update stats ONLY if this is the first time we are leaving.
        accountDetails!["pastEvents"].add(event["id"]);
      }
      await Database.updateDatabaseOnEventEnd(accountDetails, event);
      // ignore: use_build_context_synchronously
      showSnackbar(context, "You have left ${currentEvent!["title"]}.", bgColor: Colors.teal);
      fetchCurrentEvent();
      setState((){}); //!need to refresh and display message to provide feeedback of event leave.
    }else{
      //!event is not ongoing: meaning that event has expired and is simply being disposed
      accountDetails!["upcomingEvents"].remove(event["id"]);
      if(!accountDetails!['pastEvents'].contains(event['id'])){
        accountDetails!["totalJoined"]++;
        accountDetails!["topicsDiscussed"] += event["topics"].length;
        accountDetails!["friendsMade"] += (event["currentNumOfPeople"]-1); //!same reason.
        accountDetails!["pastEvents"].add(event["id"]);
      }
      await Database.updateDatabaseOnEventEnd(accountDetails, null);
    }
  }

  Widget convoWidgetBuilder(String response){
    List<String> responses = response.split("#");
    try{
      responses.remove("");
    }catch(e){

    }
    responses = responses.map((r) => r.trim()).toList();
    List<Widget> responseList = [];
    responseList.add(
      Text("Enjoy your event! Here's some food for thought:", style: spaceStyle())
    );
    responseList.add(
      const SizedBox(height: 15,),
    );
    for(String r in responses){
      responseList.add(
        Container(
          decoration: BoxDecoration(
            color: darkerMainColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(r, style: spaceStyle(color: lighterMainColor), textAlign: TextAlign.center),
          ),
        )
      );
      responseList.add(const SizedBox(height: 10));
    }
    return Column(
      children: responseList,
    );
  }
}
