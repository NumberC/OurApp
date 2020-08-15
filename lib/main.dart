import 'package:flutter/material.dart';
import 'package:our_app/FrontEnd/Pages/HomePage.dart';
import 'package:our_app/FrontEnd/Pages/UserProfile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String companyName = "OurName";

    return MaterialApp(
      title: companyName,
      theme: ThemeData(
          primaryColor: Color.fromRGBO(42, 150, 222, 1.0),
          accentColor: Color.fromRGBO(42, 150, 222, 0.2),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Color.fromRGBO(42, 150, 222, 1.0),
                displayColor: Color.fromRGBO(42, 150, 222, 1.0),
              ),
          backgroundColor: Colors.white),
      initialRoute: "/",
      onGenerateRoute: (settings) {
        var args = settings.arguments;
        switch (settings.name) {
          case "/":
            return MaterialPageRoute(
              builder: (context) => HomePage(),
            );
          case '/Profile':
            return MaterialPageRoute(
              builder: (context) => UserProfile(args),
            );
          default:
            return null;
        }
      },
      //home: HomePage(),
    );
  }
}
