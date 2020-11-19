import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class LocationLogic {
  //Everything is in KILOMETERS

  static final double nearRadius = 0.3;
  Location location = new Location();
  LocationData myLocation;
  Address myAddress;
  Future doneInitializingLocations;
  final Geoflutterfire geo = Geoflutterfire();
  GeoFirePoint myGeoLocation;

  // When instantiating this object, await initializationDone before working with the object
  LocationLogic() {
    doneInitializingLocations = initializeLocations();
  }

  Future get initializationDone => doneInitializingLocations;

  Future<void> initializeLocations() async {
    PermissionStatus locationPermission = await location.hasPermission();
    if (locationPermission != PermissionStatus.granted) return;

    myLocation = await location.getLocation();

    double latitude = myLocation.latitude;
    double longitude = myLocation.longitude;
    myGeoLocation = geo.point(latitude: latitude, longitude: longitude);

    location.onLocationChanged.listen((event) {
      myLocation = event;

      double latitude = myLocation.latitude;
      double longitude = myLocation.longitude;
      myGeoLocation = geo.point(latitude: latitude, longitude: longitude);
      //FirebaseDB().updateUserLocation(userRef);
    });
  }

  void setOnLocation(Function(LocationData) f) =>
      location.onLocationChanged.listen(f);

  LocationData getLocation() => myLocation;

  GeoPoint getLocationGeo() {
    if (myLocation == null) return null;
    return GeoPoint(myLocation.latitude, myLocation.longitude);
  }

  //TODO: actual route instead of geography
  static Future<double> getDistanceBetween(
      LocationData loc1, LocationData loc2) async {
    return await Geolocator().distanceBetween(
        loc1.latitude, loc1.longitude, loc2.latitude, loc2.longitude);
  }

  static Future<bool> isAtLocation(LocationData loc1, LocationData loc2) async {
    double distance = await getDistanceBetween(loc1, loc2);
    return distance <= nearRadius;
  }
}
