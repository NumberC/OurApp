import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/FirebasDB.dart';

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
    //TODO: do an await and change the var type of currentLocation
    currentLocation = location.getLocation();

    location.onLocationChanged.listen((LocationData currentLocation) {
      if (mapController != null) {
        /*mapController.animateCamera(CameraUpdate.newLatLng(
            LatLng(currentLocation.latitude, currentLocation.longitude)));*/
      }
      //print("Change");
      //print(currentLocation.latitude);
      //getAddress(currentLocation.latitude, currentLocation.longitude);
      //FirebaseDB().updateUserLocationById(id, loc);
    });
    print(currentLocation);
    getAddress(40.215748, -74.662743); //40.215748, -74.662743 //TODO: add await
  }

  void getAddress(lat, lng) async {
    var addresses = await Geocoder.local
        .findAddressesFromCoordinates(Coordinates(lat, lng));
    var first = addresses.first;
    print(first.addressLine);
    print(first.locality);
    print(first.featureName);
    print(first.adminArea);
    print(first.subAdminArea);
    print(first.countryName);
    //return "Address";
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
      zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      buildingsEnabled: true,
      markers: Set<Marker>(),
    );

    googleMap.markers.add(Marker(
      markerId: MarkerId("Hi"),
      position: LatLng(40.215748, -74.662743),
      icon: BitmapDescriptor.defaultMarker,
    ));

    return Scaffold(
      body: Stack(
        children: <Widget>[googleMap],
      ),
    );
  }
}
