import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<MapWidget> {
  GoogleMapController mapController;
  Location location;
  var currentLocation;

  @override
  void initState() {
    super.initState();

    location = new Location();
    currentLocation = location
        .getLocation(); //TODO: do an await and change the var type of currentLocation

    location.onLocationChanged.listen((LocationData locationData) {
      currentLocation = locationData;
      if (mapController != null) {
        mapController.animateCamera(CameraUpdate.newLatLng(
            LatLng(currentLocation.latitude, currentLocation.longitude)));
      }
      print("Change");
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    GoogleMap googleMap = GoogleMap(
      onMapCreated: (GoogleMapController controller) => {
        mapController = controller,
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(45.521563, -122.677433),
        zoom: 15.0,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      buildingsEnabled: true,
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[googleMap],
      ),
    );
  }
}