import 'package:flutter/material.dart';
import 'package:newproj/Contents/home_page.dart';
import 'package:newproj/Contents/join_page.dart';
import '../Data/data.dart';
import '../Data/useful.dart';
import '../Data/database.dart';

//if 0 = pastEvents, if 1 = upcomingEvents, if 2 = createdEvents
int loadWhichEvents = 0;
Widget actualCardList = const SizedBox();

Color cardColor = const Color.fromARGB(255, 145, 255, 202);
Color cardBorder = const Color.fromARGB(255, 0, 128, 90);

class PastEventsPage extends StatefulWidget {
  @override
  PastEventsPageState createState() => PastEventsPageState();
}

class PastEventsPageState extends State<PastEventsPage> {
  List<Map> cardList = [];
  Function? windowFunction;
  String onWindowTapTitle = "";

  @override
  void initState() {
    loadEventList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = "";

    switch (loadWhichEvents) {
      case 1:
        title = "Upcoming Events";
        cardList = getEventsByIDList(accountDetails!["upcomingEvents"]);
        cardList = sortEventsChrono(cardList);
        onWindowTapTitle = "LEAVE";
        windowFunction = (Map cardInfo, BuildContext contextIn) { //THE FUNCTION THAT IS CALLED WHEN YOU TRY TO LEAVE!
          closeWindow(contextIn);
          if (accountDetails!['createdEvents'].contains(cardInfo['id'])) {
            showMessageWindow(context, "Cannot leave",
                "Since you are the creator, you cannot leave this event.\n\nBut you can delete it through the CREATED EVENTS page.");
            return;
          }
          setState(() {
            cardInfo["currentNumOfPeople"]--;
            accountDetails!["upcomingEvents"].remove(cardInfo["id"]);
            //? UPDATE THE DATABASE (ACCOUNT->UPCOMINGEVENTS) AFTER SETTING THIS
            Database.updateDatabaseOnLeave(accountDetails!['upcomingEvents'], cardInfo["id"]);
          });
          showSnackbar(context, "You have left ${cardInfo["title"]}.",
              bgColor: Colors.teal);
        }; //UNTIL HERE
        break;
      case 2:
        title = "Your Created Events";
        cardList = getEventsByIDList(accountDetails!["createdEvents"]);
        cardList = sortEventsChrono(cardList);
        onWindowTapTitle = "DELETE";
        windowFunction = (Map cardInfo, BuildContext contextIn) {
          closeWindow(contextIn);
          String warningMessage = "Are you sure you want to delete your event, ${cardInfo["title"]}?\n\nYou cannot undo this process, and any attendees will no longer have any record of this event.";
          DateTime now = DateTime.now();
          if (stringToDateTime(cardInfo["start"]).isBefore(now) &&
              stringToDateTime(cardInfo["end"]).isAfter(now)) {
            warningMessage = "Are you sure you want to delete your event, ${cardInfo["title"]}?\n\nYou cannot undo this process. The profile stats of any attendees will not be updated and they will no longer have any record of this event, since this event has not ended.";
          }
          showWarningWindow(contextIn, "Deletion warning!",
              warningMessage,
              () {
            setState(() {
              accountDetails!["createdEvents"].remove(cardInfo['id']);
              accountDetails!["upcomingEvents"].remove(cardInfo['id']);
              fullEventList!.remove(cardInfo);
              Database.updateDatabaseOnDelete(cardInfo['id'], accountDetails!);
              showSnackbar(context, "You have deleted ${cardInfo["title"]}.",
                  bgColor: Colors.teal);
            });
          });
        };
        break;
      default:
        cardList = sortEventsChrono(cardList);
        title = "Past Events";
        cardList = getEventsByIDList(accountDetails!["pastEvents"]);
        onWindowTapTitle = "";
        windowFunction = (Map cardInfo, BuildContext context) {};
        break;
    }
    displayEvents();
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: lighterMainColor,
        appBar: AppBar(
          foregroundColor: Colors.black54,
          backgroundColor: mainColor,
          title: Text(title,
              style: spaceStyle(fontSize: 25, color: const Color.fromARGB(178, 0, 0, 0))),
          automaticallyImplyLeading: false,
        ),
        body: Stack(children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      actualCardList,
                    ]),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, 42);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("BACK", style: spaceStyle(fontSize: 30),)
                  )),
            ),
          )
        ]),
      ),
    );
  }

  // Reload a list of every event on the database.
  Future<void> loadEventList() async {
    fullEventList = await Database.getEventList();
    accountDetails = await Database.getAccountDetails();
    if(mounted){
      setState((){});
    }
  }

  // Shows the appropriate list of events on the screen.
  Future<void> displayEvents() async {
    if(accountDetails == null){
      return;
    }
    List<Widget> cardWidgetList = [];
    List createdList = accountDetails!['createdEvents'];
    for (Map cardInfo in cardList) {

      if(loadWhichEvents == 1 && createdList.contains(cardInfo['id'])){
        cardWidgetList.add(JoinPageState().card(
            cardInfo,
            () => JoinPageState().showEventInfo(context, cardInfo,
                windowFunction!, onWindowTapTitle, Colors.black),
                background: Color.fromARGB(255, 133, 255, 249)));
        cardWidgetList.add(const SizedBox(
          height: 10,
        ));
        continue;
      }
      if(loadWhichEvents == 2 && DateTime.now().isAfter(stringToDateTime(cardInfo['end']))){
        cardWidgetList.add(JoinPageState().card(
            cardInfo,
            () => JoinPageState().showEventInfo(context, cardInfo,
                windowFunction!, onWindowTapTitle, Colors.black),
                background: Color.fromARGB(255, 222, 222, 222)));
        cardWidgetList.add(const SizedBox(
          height: 10,
        ));
        continue;
      }
      cardWidgetList.add(JoinPageState().card(
          cardInfo,
          () => JoinPageState().showEventInfo(context, cardInfo,
              windowFunction!, onWindowTapTitle, Colors.black)));
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
            child: Text(
              "SHOWING ${cardList.length} EVENTS IN CHRONOLOGICAL ORDER",
              style: spaceStyle(color: const Color.fromARGB(121, 0, 0, 0)),
              textAlign: TextAlign.center,
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

}
