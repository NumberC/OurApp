import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<MapWidget> {
  Location location;
  LocationData currentLocation;
  LocationData destinationLocation;

  GoogleMapController mapController;
  String googleAPI = DotEnv().env["googleAPI"];
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  PolylineResult result;

  Marker driver = Marker(
    markerId: MarkerId("driverMark"),
    position: LatLng(40.338940, -74.653207),
    icon: BitmapDescriptor.defaultMarker,
  );

  @override
  void initState() {
    super.initState();

    location = new Location();
    asyncInit();
  }

  Future<void> asyncInit() async {
    currentLocation = await location.getLocation();
    destinationLocation = LocationData.fromMap({
      "latitude": 40.215748,
      "longitude": -74.662743,
    });

    location.onLocationChanged.listen((LocationData currentLocation) async {
      if (mapController != null) {
        currentLocation = await location.getLocation();
        mapController.animateCamera(CameraUpdate.newLatLng(
            LatLng(currentLocation.latitude, currentLocation.longitude)));
      }
    });
    await getAddress(currentLocation.latitude, currentLocation.longitude);
    //await _getPolyline();
  }

  Future<void> getAddress(lat, lng) async {
    var addresses = await Geocoder.local
        .findAddressesFromCoordinates(Coordinates(lat, lng));
    var first = addresses.first;
    print(first.addressLine);

    String country = first.countryCode;
    String state = first.adminArea;
    String township = first.locality;
    print("Z- $country => $state => $township => drivers");
  }

  _addPolyLine() {
    Polyline polyline = Polyline(
        polylineId: PolylineId("poly"),
        color: Colors.red,
        points: polylineCoordinates);
    polylines.add(polyline);
  }

  _getPolyline() async {
    result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPI,
        new PointLatLng(40.343580,
            -74.651756), // currentLocation.latitude, currentLocation.longitude
        new PointLatLng(40.338940, -74.653207));

    print("--------");
    print(result);
    print(result.points);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  @override
  Widget build(BuildContext context) {
    GoogleMap googleMap;

    return FutureBuilder(
      future: asyncInit(),
      builder: (context, snapshot) {
        googleMap = GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            //_getPolyline();
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: 15.0,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          buildingsEnabled: false,
          markers: Set<Marker>(),
          polylines: polylines,
        );
        googleMap.markers.add(driver);
        return googleMap;
      },
    );
  }
}
