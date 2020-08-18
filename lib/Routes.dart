import 'package:flutter/material.dart';

import 'FrontEnd/Pages/HomePage.dart';
import 'FrontEnd/Pages/TestSearch.dart';
import 'FrontEnd/Pages/UserProfile.dart';

class Routes {
  static const String homeRoute = "/";
  static const String profileRoute = "/Profile";
  static const String testRoute = "/Test";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    var args = settings.arguments;
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(builder: (context) => HomePage());
      case profileRoute:
        return MaterialPageRoute(builder: (context) => UserProfile(args));
      case testRoute:
        return MaterialPageRoute(builder: (context) => TestSearch());
      default:
        return null;
    }
  }
}
