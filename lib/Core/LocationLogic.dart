import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class LocationLogic {
  //Everything is in KILOMETERS
  static final double nearRadius = 10;

  Location location = new Location();
  LocationData myLocation;
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
    getGeoFirePoint();

    location.onLocationChanged.listen((event) {
      myLocation = event;
      getGeoFirePoint();
    });
  }

  GeoFirePoint getGeoFirePoint() {
    double latitude = myLocation.latitude;
    double longitude = myLocation.longitude;
    return geo.point(latitude: latitude, longitude: longitude);
  }

  void setOnLocation(Function(LocationData) f) =>
      location.onLocationChanged.listen(f);

  LocationData getLocation() => myLocation;

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
