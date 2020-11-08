import 'package:catcher/catcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:our_app/Core/Business.dart';
import 'package:our_app/Core/FirebaseDB.dart';
import 'package:our_app/Routes.dart';
import 'package:our_app/globalVars.dart' as globalVars;
import 'package:stripe_payment/stripe_payment.dart';

Future main() async {
  //Initialize all our global or static classes
  final geo = Geoflutterfire();
  await DotEnv().load('.env');
  Business.init();
  await FirebaseDB.initializeApp();
  await globalVars.locationLogic.doneInitializingLocations;

  CatcherOptions debugOptions =
      CatcherOptions(DialogReportMode(), [ConsoleHandler()]);

  Catcher(MyApp(), debugConfig: debugOptions, releaseConfig: null);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String companyName = "OurName";

    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    return MaterialApp(
      //navigatorKey: Catcher.navigatorKey,
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
