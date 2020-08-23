import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:our_app/Core/FirebasDB.dart';

class LocationLogic {
  Location location = new Location();
  LocationData myLocation;
  Address myAddress;

  Future<LocationData> getLocation() async {
    myLocation = await location.getLocation();
    location.onLocationChanged.listen((event) {
      myLocation = event;
      //FirebaseDB().updateUserLocation(userRef);
    });
    return myLocation;
  }

  Future<Address> getAddress(latitude, longitude) async {
    if (latitude == null || longitude == null) return null;
    List<Address> addresses = await Geocoder.local
        .findAddressesFromCoordinates(Coordinates(latitude, longitude));
    myAddress = addresses.first;
    return myAddress;
  }

  String getCountryCode(Address address) {
    return address != null ? address.countryCode : null;
  }

  String getState(Address address) {
    return address != null ? address.adminArea : null;
  }

  String getTown(Address address) {
    return address != null ? address.locality : null;
  }

  Future<List<String>> getAllInfo() async {
    await getLocation();
    await getAddress(myLocation.latitude, myLocation.longitude);
    String country = getCountryCode(myAddress);
    String state = getState(myAddress);
    String town = getTown(myAddress);
    return [country, state, town];
  }

  //TODO: actual route instead of geography
  Future<double> getDistanceBetween(
      LocationData loc1, LocationData loc2) async {
    return await Geolocator().distanceBetween(
        loc1.latitude, loc1.longitude, loc2.latitude, loc2.longitude);
  }

  Future<double> getDistanceBetweenGeo(GeoPoint loc1, GeoPoint loc2) async {
    return await Geolocator().distanceBetween(
        loc1.latitude, loc1.longitude, loc2.latitude, loc2.longitude);
  }
}
