import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

class Test extends StatefulWidget {
  @override
  TestState createState() => TestState();
}

class TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new FutureBuilder(
        future: PlacesAutocomplete.show(
            context: context,
            apiKey: "AIzaSyADIuHSXXBc0aASdEMPhoStyU5BaBaaKvk",
            mode: Mode.fullscreen,
            language: "fr",
            components: [Component(Component.country, "fr")]),
        builder: (BuildContext context, AsyncSnapshot<Prediction> snapshot) {
          return PredictionTile(
            prediction: snapshot.data,
          );
        },
      ),
    );
  }
}
