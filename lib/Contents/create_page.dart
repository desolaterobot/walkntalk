import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:newproj/Contents/join_page.dart';
import '../Data/useful.dart';
import '../Data/data.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'map_page.dart';
import '../Data/database.dart';

Color textInputColor = Color.fromARGB(255, 247, 242, 249);

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  CreatePageState createState() => CreatePageState();
}

//data buffer to contain all the data entered in this form.
late Map<String, dynamic> createdEvent = {...defaultEvent};

//template to contain the default values.
Map<String, dynamic> defaultEvent = {
  "id": 0,
  "title": "",
  "author": "Username",
  "maxNumOfPeople": "5",
  "currentNumOfPeople": 1,
  "topics": [],
  "start": "",
  "end": "",
  "description": "",
  "type": "WALKING",
  "location":
      [], //list of points, each point is a list made of latitude and longitude, both doubles
};

class CreatePageState extends State<CreatePage> {
  @override
  void initState() {
    getEventAuthor();
    createdEvent["location"] = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updateDateStrings();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        nameField("Name your Event", "Think of something eye-catching..."),
        numberField("Max number of people", ""),
        modeOfActivity(),
        Divider(
            color: Color.fromARGB(65, 0, 126, 72),
            height: 25,
            indent: 20,
            endIndent: 20,
            thickness: 1.5),
        timeSelectionButtons(context),
        Divider(
            color: Color.fromARGB(65, 0, 126, 72),
            height: 25,
            indent: 20,
            endIndent: 20,
            thickness: 1.5),
        Row(
          children: [
            Expanded(child: SizedBox()),
            topicField(
                topics.isEmpty ? "No topics selected." : "Topics selected:"),
            Expanded(child: SizedBox()),
          ],
        ),
        Divider(
            color: Color.fromARGB(65, 0, 126, 72),
            height: 25,
            indent: 20,
            endIndent: 20,
            thickness: 1.5),
        locationSelectButton(),
        Divider(
            color: Color.fromARGB(65, 0, 126, 72),
            height: 25,
            indent: 20,
            endIndent: 20,
            thickness: 1.5),
        descriptionField("Event description",
            "Max 200 characters.\nexact meetup location...\nlandmarks of interest...\narticles of clothing for identification..."),
        createButton(),
      ]),
    );
  }

  Widget modeOfActivity() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 25),
        DropdownMenu(
          label: Text(
            "Mode Of Activity",
            style: spaceStyle(fontSize: 18),
            selectionColor: Color.fromARGB(255, 247, 242, 249),
          ),
          enableSearch: false,
          initialSelection: createdEvent["type"],
          enableFilter: false,
          requestFocusOnTap: true,
          textStyle: spaceStyle(fontSize: 20),
          menuHeight: 200,
          dropdownMenuEntries:
              activities.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry(value: value, label: value);
          }).toList(),
          onSelected: (value) {
            print(value);
            createdEvent["type"] = value;
          },
        )
      ],
    );
  }

  Widget nameField(String title, String hintText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: spaceStyle(fontSize: 18)),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController()..text = createdEvent["title"],
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              hintText: hintText,
              filled: true,
              fillColor: textInputColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 43, 128, 48),
                  width: 1,
                ),
              ),
            ),
            style: spaceStyle(fontSize: 16),
            onChanged: (value) {
              createdEvent["title"] = value;
            },
          ),
        ],
      ),
    );
  }

  Widget numberField(String title, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(title, style: spaceStyle(fontSize: 18)),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140, maxHeight: 80),
          child: TextField(
            controller: TextEditingController()
              ..text = createdEvent["maxNumOfPeople"],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: textInputColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.0),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 43, 128, 48),
                  width: 5,
                ),
              ),
            ),
            style: spaceStyle(fontSize: 30),
            onChanged: (value) {
              createdEvent["maxNumOfPeople"] = value;
            },
          ),
        ),
      ],
    );
  }

  Widget topicField(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 6),
        Text(title, style: spaceStyle(fontSize: 18)),
        const SizedBox(height: 6),
        topics.isEmpty
            ? const SizedBox()
            : ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 340),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: JoinPageState().tagListWidget(topics,
                      fontSize: 17, wrapAlign: WrapAlignment.center),
                ),
              ),
        const SizedBox(height: 6),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Color.fromARGB(255, 86, 208, 245)),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            fixedSize: MaterialStateProperty.all(Size(200, 30)),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)))),
          ),
          onPressed: () {
            getTopics(context, "Select topic...");
          },
          child: Text(
            "SELECT TOPICS",
            style: spaceStyle(),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget descriptionField(String title, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text(title, style: spaceStyle(fontSize: 18)),
        const SizedBox(height: 6),
        TextField(
          maxLines: 6,
          controller: TextEditingController()
            ..text = createdEvent["description"],
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            hintText: hintText,
            filled: true,
            fillColor: textInputColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.0),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 43, 128, 48),
                width: 1,
              ),
            ),
          ),
          style: spaceStyle(fontSize: 15),
          onChanged: (value) {
            createdEvent["description"] = value;
          },
        ),
      ],
    );
  }

  //the following local variables are required to
  DateTime dateTimeRightNow = DateTime.now().subtract(
      Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute));
  //default start datetime is right now. default end date time is 1h from now.
  late DateTime chosenDateTime = dateTimeRightNow;
  late TimeOfDay startTime = TimeOfDay.now();
  late TimeOfDay endTime =
      TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

  //everytime date or time gets updated, this is called to update the strings that are stored in the buffer
  void updateDateStrings() {
    createdEvent["start"] = dateTimeToString(chosenDateTime
        .add(Duration(hours: startTime.hour, minutes: startTime.minute)));
    createdEvent["end"] = dateTimeToString(chosenDateTime
        .add(Duration(hours: endTime.hour, minutes: endTime.minute)));
  }

  Widget showTime(TimeOfDay time) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Text(
          DateFormat('hh:mm a')
              .format(DateTime(0, 0, 0, time.hour, time.minute)),
          style: spaceStyle(fontSize: 22)),
    );
  }

  Widget showDate(DateTime dateTime) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(DateFormat('dd/MM/yyyy').format(dateTime),
          style: spaceStyle(fontSize: 30)),
    );
  }

  Widget timeSelectionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Row(
            children: [
              Text("Date:", style: spaceStyle(fontSize: 25)),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 247, 242, 249)),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  //fixedSize: MaterialStateProperty.all(Size(200, 50)),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
                onPressed: () => getDate(context),
                child: showDate(chosenDateTime),
              ),
              const SizedBox(height: 10),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(children: [
                Text("Start\nTime", style: spaceStyle(fontSize: 14)),
                SizedBox(width: 5),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 247, 242, 249)),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    fixedSize: MaterialStateProperty.all(Size(125, 50)),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                  ),
                  onPressed: () => getTime(context, true),
                  child: showTime(startTime),
                ),
              ]),
              const SizedBox(width: 5),
              Row(children: [
                Text("End\nTime", style: spaceStyle(fontSize: 14)),
                SizedBox(width: 5),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 247, 242, 249)),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    fixedSize: MaterialStateProperty.all(Size(125, 50)),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                  ),
                  onPressed: () => getTime(context, false),
                  child: showTime(endTime),
                ),
              ])
            ],
          ),
        ],
      ),
    );
  }

  Widget createButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Color.fromARGB(255, 172, 231, 114)),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            fixedSize: MaterialStateProperty.all(Size(300, 50)),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)))),
          ),
          onPressed: () async {

            if (validateFormData()) {
              showSnackbar(context, "Creating event...", bgColor: Colors.teal); 

              //update account details. //! updating must be this particular format: add global, add global, then commit.
              accountDetails!["upcomingEvents"].add(createdEvent["id"]);
              accountDetails!["createdEvents"].add(createdEvent["id"]);
              await Database.updateAccountDetails(accountDetails!);

              //upload the event to the database.
              await Database.addEvent(createdEvent);
              //increment this ID for future use.
              await Database.incrementGlobalID();

              //once done, show a confirmation window.
              showMessageWindow(context, "Event created!",
                  "Your event, ${createdEvent["title"]} has been successfully uploaded. Have fun!");
              
              setState(() {
                createdEvent = {...defaultEvent}; //reset to default values.
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("CREATE EVENT", style: spaceStyle(fontSize: 30)),
          ),
        ),
      ),
    );
  }

  Column locationColumn = Column(
    children: [
      Text("No location selected.",
          style: spaceStyle(fontSize: 15, color: mainColor)),
    ],
  );

  Widget topicListWindow() {
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

  Widget locationSelectButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            Stack(alignment: Alignment.bottomRight, children: [
              Container(
                constraints:
                    BoxConstraints(minHeight: 55, minWidth: 400, maxWidth: 400),
                decoration: BoxDecoration(
                    color: darkerMainColor,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: locationColumn,
                ),
              ),
              if (createdEvent["location"].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: IconButton(
                    color: mainColor,
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    icon: Icon(Icons.location_searching_outlined),
                    onPressed: () {
                      isSelectingPath = false;
                      coordinateListToBeShown = createdEvent["location"];
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapPage()),
                      );
                    },
                  ),
                ),
            ]),
            SizedBox(height: 5),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Color.fromARGB(255, 86, 208, 245)),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
                //fixedSize: MaterialStateProperty.all(Size(200, 40)),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
              onPressed: () async {
                isSelectingPath = true;
                List<List<double>>? selectedPointList = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapPage()),
                );
                if (selectedPointList != null) {
                  createdEvent["location"] = selectedPointList;
                }
                getRoute();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("SELECT LOCATIONS", style: spaceStyle()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> topics = [];
  TextEditingController textController = TextEditingController();

  //FUNCTIONAL METHODS///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //Fetch the length of full event list for ID purposes.
  Future<void> getEventAuthor() async {
    List eventList = await Database.getEventList();
    accountDetails = await Database.getAccountDetails();
    //print("ACCOUNT DETAILS " + accountDetails.toString());
    int id = eventList[0]["currentNumOfPeople"];
    createdEvent['id'] = id;
    createdEvent['author'] = accountDetails!['username'];
    //print(createdEvent);
  }

  //Opens the time window for the user to select the time.
  void getTime(BuildContext context, bool selectingStartTime) async {
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) {
      return;
    }
    final newdate =
        dateTimeRightNow.add(Duration(hours: time.hour, minutes: time.minute));
    setState(() {
      if (selectingStartTime) {
        if (newdate.isAfter(dateTimeRightNow
            .add(Duration(hours: endTime.hour, minutes: endTime.minute)))) {
          showSnackbar(context, "Start time must be before end time.",
              bgColor: Colors.red.shade800);
          return;
        }
        startTime = time;
      } else {
        if (newdate.isBefore(dateTimeRightNow
            .add(Duration(hours: startTime.hour, minutes: startTime.minute)))) {
          showSnackbar(context, "End time must be after start time.",
              bgColor: Colors.red.shade800);
          return;
        }
        endTime = time;
      }
    });
  }

  //Opens the date selector window to select the date.
  void getDate(BuildContext context) async {
    final dateChosen = await showDatePicker(
        context: context,
        firstDate: dateTimeRightNow,
        lastDate: DateTime(2100),
        initialDate: dateTimeRightNow);
    if (dateChosen == null) {
      return;
    }
    setState(() {
      chosenDateTime = dateChosen;
    });
  }

  //Opens the topic selection window to select topics.
  Future getTopics(BuildContext context, String title) {
    textController.text = "";
    return showDialog(
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                hintText: "Topics seperated by commas...",
                filled: true,
                fillColor: Colors.green.shade100,
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(7.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 43, 128, 48),
                    width: 1,
                  ),
                ),
              ),
              style: spaceStyle(fontSize: 10),
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
                    child: topicListWindow())),
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
                style: spaceStyle(fontSize: 21, color: Colors.red.shade700),
              )),
          TextButton(
              onPressed: () {
                List<String> topicBuffer = textController.text
                  .split(",")
                  .map((e) => e.trim().toUpperCase())
                  .toList();
                topicBuffer = topicBuffer.toSet().toList();
                if (topicBuffer.contains("")) {
                  topicBuffer.remove("");
                }
                for(String topic in topicBuffer){
                  if(topic.length > 15){
                    showMessageWindow(context, "Topic too long", "One of your custom topics, ${topic}, is a bit too long. Try a word/phrase of less than 15 characters.");
                    return;
                  }
                }
                closeWindow(context);
                setState(() {
                  topics = topicBuffer;
                  if (topics.isNotEmpty && topics[0] == "") {
                    topics = [];
                  }
                });
              },
              child: Text(
                "CONFIRM",
                style: spaceStyle(fontSize: 21, color: Colors.green.shade700),
              ))
        ],
      ),
    );
  }

  //Obtains the selected coordinates and displays the route locations.
  void getRoute() async {
    List<List<double>> coordinateList = createdEvent["location"];
    List<String> addressList = [];
    int x = 1;
    for (List<double> coordinate in coordinateList) {
      addressList.add(
          "$x. ${await MapPageState().getStreetNameFromLatLng(LatLng(coordinate[0], coordinate[1]))}");
      x++;
    }
    List<Text> textList = [];
    for (String address in addressList) {
      textList.add(
          Text(address, style: spaceStyle(fontSize: 18, color: mainColor)));
    }
    setState(() {
      locationColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: textList,
      );
    });
  }

  //Checks if all entries are valid, only then this will return true.
  bool validateFormData() {
    List<Map> getEventsByIDList(List idList) {
      List<Map<dynamic, dynamic>> mapList = [];
      List newIdList = idList.toSet().toList();
      for (int id in newIdList) {
        for (Map event in fullEventList!) {
          if (event["id"] == id) {
            mapList.add(event);
          }
        }
      }
      return mapList;
    }
    
    //validate if the created event clashes with another event you have joined.
    List<Map> createdEvents = getEventsByIDList(accountDetails!["createdEvents"]);
    createdEvents.addAll(getEventsByIDList(accountDetails!["upcomingEvents"]));

    if (createdEvent["title"] == "") {
      showSnackbar(context, "Please enter a title.");
      return false;
    }
    if (createdEvent["title"].length > 50){
      showSnackbar(context, "Keep the title length under 50 characters please!");
      return false;
    }
    try {
      int.parse(createdEvent["maxNumOfPeople"]);
    } catch (e) {
      print(e);
      showSnackbar(context, "Number field is non-numerical.");
      return false;
    }
    if(int.parse(createdEvent["maxNumOfPeople"]) < 1){
      showSnackbar(context, "Number of people must be more than zero.");
      return false;
    }
    if (topics.isEmpty) {
      showSnackbar(context, "Please enter at least one topic.");
      return false;
    }
    if (createdEvent["location"].isEmpty) {
      showSnackbar(context, "Please enter a location.");
      return false;
    }
    if (createdEvent["description"].length > 200) {
      showSnackbar(context,
          "Your description must be less than 200 characters. Leave some content for your conversations later!");
      return false;
    }

    //CHECK FOR CLASH
    for (Map event in createdEvents) {
      if (eventClash(createdEvent, event)) {
        showSnackbar(context,
            "This event clashes with another joined event, ${event["title"]}. Try rescheduling.");
        return false;
      }
    }

    createdEvent["maxNumOfPeople"] = int.parse(createdEvent["maxNumOfPeople"]);
    createdEvent["topics"] = topics;
    return true;
  }
}
