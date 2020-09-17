import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class LocationLogic {
  //Everything is in KILOMETERS

  static final double nearRadius = 0.3;
  Location location = new Location();
  LocationData myLocation;
  Address myAddress;
  Future doneInitializingLocations;

  // When instantiating this object, await initializationDone before working with the object
  LocationLogic() {
    doneInitializingLocations = initializeLocations();
  }

  Future get initializationDone => doneInitializingLocations;

  Future<void> initializeLocations() async {
    GeolocationStatus locationPermission =
        await Geolocator().checkGeolocationPermissionStatus();
    if (locationPermission != GeolocationStatus.granted) return;

    myLocation = await location.getLocation();
    location.onLocationChanged.listen((event) {
      myLocation = event;
      //FirebaseDB().updateUserLocation(userRef);
    });
  }

  LocationData getLocation() {
    return myLocation;
  }

  Future<Address> getMyAddress() async {
    if (myLocation == null) return null;
    return await getAddress(myLocation.latitude, myLocation.longitude);
  }

  static Future<Address> getAddress(latitude, longitude) async {
    if (latitude == null || longitude == null) return null;
    List<Address> addresses = await Geocoder.local
        .findAddressesFromCoordinates(Coordinates(latitude, longitude));
    return addresses.first;
  }

  static String getCountryCode(Address address) {
    return address != null ? address.countryCode : null;
  }

  static String getState(Address address) {
    return address != null ? address.adminArea : null;
  }

  static String getTown(Address address) {
    return address != null ? address.locality : null;
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
