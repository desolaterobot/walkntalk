import 'package:flutter/material.dart';
import 'package:newproj/joinPage.dart';
import 'data.dart';
import 'useful.dart';

/* List<Map> pastEvents = [];
List<Map> upcomingEvents = []; */

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
  Widget build(BuildContext context) {
    String title = "";

    switch (loadWhichEvents) {
      case 1:
        title = "Upcoming Events";
        cardList = getEventsByIDList(accountDetails["upcomingEvents"]);
        onWindowTapTitle = "LEAVE";
        windowFunction = (Map cardInfo){
          closeWindow(context);
          if(cardInfo["author"] == accountDetails["username"]){
            showMessageWindow(context, "Cannot leave", "Since you are the creator, you cannot leave this event.\n\nBut you can delete it through the CREATED EVENTS page.");
            return;
          }
          setState(() {
            cardInfo["currentNumOfPeople"]--;
            accountDetails["upcomingEvents"].remove(cardInfo["id"]);
            //todo UPDATE THE DATABASE (ACCOUNT->UPCOMINGEVENTS) AFTER SETTING THIS!!
          });
          showSnackbar(context, "You have left ${cardInfo["title"]}.", bgColor: Colors.teal);
        };
        break;
      case 2:
        title = "Your Created Events";
        cardList = getEventsByIDList(accountDetails["createdEvents"]);
        onWindowTapTitle = "DELETE";
        windowFunction = (Map cardInfo){
          closeWindow(context);
          showWarningWindow(context, "Delete this event?", "Are you sure you want to delete your event, ${cardInfo["title"]}?\n\nYou will not be able to recover from this action.", (){  
            setState((){
              print("delete!!!!");
              accountDetails["createdEvents"].remove(cardInfo);
              fullEventList.remove(cardInfo);
              //todo UPDATE THE DATABASE (ACCOUNT->CREATEDEVENTS, EVENTLIST) AFTER SETTING THIS!!
              //ProfilePageState().initState();
              closeWindow(context);
              showSnackbar(context, "You have deleted ${cardInfo["title"]}.", bgColor: Colors.teal);
            });
          });
        };
        break;
      default:
        title = "Past Events";
        cardList = getEventsByIDList(accountDetails["pastEvents"]);
        onWindowTapTitle = "";
        windowFunction = (Map cardInfo){};
        break;
    }
    loadCardListWidget();
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: spaceStyle(fontSize: 25)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, 42);
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                actualCardList,
              ]
            ),
          ),
        ),
      ),
    );
  }


  Future<void> loadCardListWidget() async {
    //await Future.delayed(const Duration(seconds: 1)); //artificial sleep for 1 second to simulate database fetch

    List<Widget> cardWidgetList = [];
    for (Map cardInfo in cardList) {
      cardWidgetList.add(JoinPageState().card(cardInfo, ()=>JoinPageState().showCardWindow(context, cardInfo, windowFunction!, onWindowTapTitle, Colors.black)));
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
              "SHOWING ${cardList.length} EVENTS",
              style: spaceStyle(color: const Color.fromARGB(121, 0, 0, 0)),
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