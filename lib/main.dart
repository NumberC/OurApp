import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Routes.dart';
import 'package:stripe_payment/stripe_payment.dart';

Future main() async {
  await DotEnv().load('.env');
  Business.init();
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
      initialRoute: Routes.homeRoute,
      onGenerateRoute: (settings) => Routes.generateRoute(settings),
      //home: HomePage(),
    );
  }
}
