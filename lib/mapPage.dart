import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:newproj/joinPage.dart';
import 'package:newproj/main.dart';
import 'useful.dart';
import 'package:geocoding/geocoding.dart' as GEO;

//there's two modes to this page: SHOWING a given path, or SELECTING a given path. this is toggled by this following global boolean:
//if true: map page is only showing the path
//if false: map page is showing a path selection interface.
bool isSelectingPath = true;
LocationData? currentLocation;

//if isSelectingPath is false, coordinateListToBeShown must be set manually before navigating to this page:
List<List<double>> coordinateListToBeShown = [];

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Set<Marker> markerSetToBeShown = {};
  String title = isSelectingPath ? "Select Location" : "Location Of Event";
  late List<LatLng> polylinePoints = [];
  Set<Marker> selectedMarker = {};

  @override
  Widget build(BuildContext context) {
    double? distanceOfTrail = null;
    if (!isSelectingPath) {
      distanceOfTrail = calculateDistanceOfTrail(coordinateListToBeShown);
      showConnectingLines();
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
                        target: isSelectingPath
                            ? LatLng(currentLocation!.latitude!,
                                currentLocation!.longitude!)
                            : polylinePoints[0],
                        zoom: 16),
                    markers:
                        isSelectingPath ? selectedMarker : markerSetToBeShown,
                    onTap: addMarker,
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
            isSelectingPath
                ? Align(
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
                          child: Text(
                            "TAP ANYWHERE ON THE MAP TO PLACE A POINT.\n\nTAP A POINT, THEN TAP THE POP-UP TO REMOVE IT.",
                            style:
                                spaceStyle(fontSize: 15, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ))
                : distanceOfTrail != null
                    ? Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: 10, left: 10, right: 70),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Color.fromARGB(185, 0, 145, 77),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "EST. DISTANCE OF TRAIL: ${distanceOfTrail.toStringAsFixed(2)}KM",
                                style: spaceStyle(
                                    fontSize: 15, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ))
                    : const SizedBox(),
            //! the button to confirm
            Padding(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                  onPressed: () {
                    //what to do during confirmation??
                    //!!WE WERE HERE
                    if (isSelectingPath) {
                      List<List<double>> coordinateList = polylinePoints
                          .map((polyPoint) =>
                              [polyPoint.latitude, polyPoint.longitude])
                          .toList();
                      if (polylinePoints.isEmpty) {
                        showSnackbar(
                            context, "Please select at least one location.");
                        return;
                      }
                      Navigator.pop(context, coordinateList);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(isSelectingPath ? "CONFIRM\nPATH" : "BACK",
                        style: spaceStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                  )),
            ),
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: isSelectingPath
                    ? ElevatedButton(
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
                              style: spaceStyle(color: Colors.white),
                              textAlign: TextAlign.center),
                        ))
                    : const SizedBox(),
              ),
            )
          ],
        ));
  }

  @override
  void initState() {
    if (!isSelectingPath) showMarkers();
    getLocation();
    super.initState();
  }

  //FUNCTIONAL METHODS////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //update the connecting lines between markers every time a marker is added or removed, during SELECTING mode.
  void updatePolyPoints() {
    List<LatLng> points =
        selectedMarker.map((marker) => marker.position).toList();
    setState(() {
      polylinePoints = points;
    });
  }

  //show the connecting lines between markers, during SHOWING mode.
  void showConnectingLines() {
    List<LatLng> points = coordinateListToBeShown
        .map((coordinate) => listToLatLng(coordinate))
        .toList();
    setState(() {
      polylinePoints = points;
    });
  }

  //removes a marker during SELECTING mode.
  void removeMarker(LatLng position) {
    //!REMOVAL OF A MARKER
    setState(() {
      selectedMarker.removeWhere((marker) => marker.position == position);
      polylinePoints.remove(position);
    });
  }

  //finds the street name from a LatLng data structure.
  Future<String> getStreetNameFromLatLng(LatLng position) async {
    String streetName = "";
    final List<GEO.Placemark> placemarks = await GEO.placemarkFromCoordinates(
        position.latitude, position.longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      streetName = placemarks[0].street!;
    }
    return streetName;
  }

  //what happens if the map is tapped, to add a marker during SELECTING mode.
  void addMarker(LatLng position) async {
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

  //getting the current location
  void getLocation() {
    Location location = Location();
    location.getLocation().then((location) {
      print(
          "GETTING CURRENT LOCATION ${location.latitude}, ${location.longitude}");
      setState(() {
        currentLocation = location;
      });
      return [location.latitude, location.longitude];
    });
    return null;
  }

  //takes a coordinate and converts it to a LatLng data type
  LatLng listToLatLng(List<double> coordinates) {
    return LatLng(coordinates[0], coordinates[1]);
  }

  //show the markers, during SHOWING mode.
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

  //takes a trail of points, then estimates the distance of the trail
  double? calculateDistanceOfTrail(List<List<double>> trail) {
    if (trail.length < 2) {
      return null;
    }
    List<double> p1 = trail[0];
    List<double> p2;
    double distance = 0;
    for (int x = 1; x < trail.length; x++) {
      p2 = trail[x];
      distance += JoinPageState().calculateDistance(p1, p2);
      p1 = trail[x];
    }
    return distance;
  }
}
