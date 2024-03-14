import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:newproj/main.dart';
import 'useful.dart';
import 'package:geocoding/geocoding.dart' as GEO;

//if true: map page is only showing the path
//if false: map page is showing a path selection interface.
bool isSelectingPath = true;
LocationData? currentLocation;

//if isSelectingPath is false
List<List<double>> coordinateListToBeShown = [];
Set<Marker> markerSetToBeShown = {};

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  String title = isSelectingPath ? "Select Location" : "Location Of Event";
  late List<LatLng> polylinePoints = [];

  LatLng singaporePosition =
      const LatLng(1.3609154307106606, 103.80655535777764);

  @override
  void initState() {
    if(!isSelectingPath)showMarkers();
    getLocation();
    super.initState();
  }

  Set<Marker> selectedMarker = {};

  void updatePolyPoints() {
    List<LatLng> points =
        selectedMarker.map((marker) => marker.position).toList();
    setState(() {
      polylinePoints = points;
    });
  }

  void showPolyLinePoints(){
    List<LatLng> points = coordinateListToBeShown.map((coordinate) => listToLatLng(coordinate)).toList();
    setState(() {
      polylinePoints = points;
    });
  }

  void removeMarker(LatLng position) {
    //!REMOVAL OF A MARKER
    setState(() {
      selectedMarker.removeWhere((marker) => marker.position == position);
      polylinePoints.remove(position);
    });
  }

  Future<String> getStreetNameFromLatLng(LatLng position) async {
    String streetName = "";
    final List<GEO.Placemark> placemarks = await GEO.placemarkFromCoordinates(
        position.latitude, position.longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      streetName = placemarks[0].street!;
    }
    return streetName;
  }

  void onMapTap(LatLng position) async {
    if (isSelectingPath) {
      String streetName = await getStreetNameFromLatLng(position);

      Marker mark = Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(
          title: streetName,
          onTap: () => removeMarker(position),
        ),
      );

      //!ADDING OF A MARKER
      setState(() {
        selectedMarker.add(mark);
        polylinePoints.add(position);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!isSelectingPath){
      showPolyLinePoints();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(title, style: spaceStyle(fontSize: 25)),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            //! the map itself
            currentLocation == null
                ? loadingSign()
                : GoogleMap(
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  compassEnabled: false,
                  zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                        target: isSelectingPath ? LatLng(currentLocation!.latitude!, currentLocation!.longitude!) : polylinePoints[0],
                        zoom: 16),
                    markers: isSelectingPath
                        ? selectedMarker
                        : markerSetToBeShown,
                    onTap: onMapTap,
                    polylines: {
                      Polyline(
                        polylineId: PolylineId('polyline'),
                        points: polylinePoints,
                        color: Colors.red,
                        width: 3,
                      ),
                    },
                  ),
            //! instructions
            isSelectingPath ? Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: EdgeInsets.only(top: 10, left: 10, right: 70),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color.fromARGB(185, 0, 145, 77),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("TAP ANYWHERE ON THE MAP TO PLACE A POINT.\n\nTAP A POINT, THEN TAP THE POP-UP TO REMOVE IT.", style: spaceStyle(fontSize: 15, color: Colors.white), textAlign: TextAlign.center,),
                  ),
                ),
              )
            ) : const SizedBox(),
            //! the button to confirm
            Padding(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                  onPressed: (){
                    //what to do during confirmation??
                    //!!WE WERE HERE
                    if(isSelectingPath){
                      List<List<double>> coordinateList = polylinePoints.map((polyPoint) => [polyPoint.latitude, polyPoint.longitude]).toList();
                      if(polylinePoints.isEmpty){
                        showSnackbar(context, "Please select at least one location.");
                        return;
                      }
                      Navigator.pop(context, coordinateList);
                    }else{
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(isSelectingPath ? "CONFIRM\nPATH" : "BACK",
                        style: spaceStyle(color: Colors.white), textAlign: TextAlign.center),
                  )),
            ),
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: isSelectingPath ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        polylinePoints = [];
                        selectedMarker = {};
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("REMOVE\nALL",
                          style: spaceStyle(color: Colors.white), textAlign: TextAlign.center),
                    )) : const SizedBox(),
              ),
            )
          ],
        ));
  }

  void getLocation() {
    Location location = Location();
    location.getLocation().then((location) {
      print("HELLOOOOOO ${location.latitude}, ${location.longitude}");
      setState(() {
        currentLocation = location;
      });
    });
  }

  LatLng listToLatLng(List<double> coordinates) {
    return LatLng(coordinates[0], coordinates[1]);
  }

  void showMarkers() async {
    Set<Marker> markerSet = Set();
    int x = 0;
    for (List<double> coordinate in coordinateListToBeShown) {
      String name = await getStreetNameFromLatLng(listToLatLng(coordinate));
      markerSet.add(Marker(
          markerId: MarkerId("point ${coordinate.toString()}"),
          position: listToLatLng(coordinate),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          infoWindow: InfoWindow(
            title: name,
          )));
      x++;
    }
    setState(() {
      markerSetToBeShown = markerSet;
    });
  }
}
