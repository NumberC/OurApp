import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:our_app/map.dart';

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
      home: MyHomePage(title: companyName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /*
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => HomeResults()),
  );
  */

  Widget getProfileBar(context, name, price) {
    Color primaryColor = Theme.of(context).primaryColor;
    Color accentColor = Theme.of(context).accentColor;
    double borderRadius = 20;

    Container profileBar = Container(
      width: 317,
      height: 59,
      decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
    );

    Container profilePic = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
    );

    Stack finalStack = Stack(
      children: <Widget>[
        profileBar,
        Positioned(
          child: profilePic,
          left: 10,
          top: 5,
        ),
        Positioned(
          child: Text('$name'),
          left: 70,
          top: 10,
        ),
        Positioned(
          child: Text('\$$price'),
          right: 10,
          top: 10,
        ),
      ],
    );

    for (int i = 0; i < 5; i++) {
      finalStack.children.add(Positioned(
        child: Icon(
          Icons.star,
          color: Colors.white,
        ),
        left: 70.0 + i * 20,
        top: 30,
      ));
    }

    return finalStack;
  }

  Widget getInputTxt(context, title) {
    Color primaryColor = Theme.of(context).primaryColor;
    TextTheme textTheme = Theme.of(context).textTheme;

    UnderlineInputBorder txtFieldBorder =
        UnderlineInputBorder(borderSide: BorderSide(color: primaryColor));

    return TextField(
      decoration: InputDecoration(
          hintText: title,
          hintStyle: textTheme.bodyText2,
          enabledBorder: txtFieldBorder,
          focusedBorder: txtFieldBorder,
          disabledBorder: txtFieldBorder),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    Color accentColor = Theme.of(context).accentColor;
    Color backgroundColor = Theme.of(context).backgroundColor;
    TextTheme textTheme = Theme.of(context).textTheme;
    MapState myMap = MapState();
    myMap.initState();
    myMap.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: true,
        leading: Icon(
          Icons.home,
          color: primaryColor,
        ),
        actions: [
          Icon(
            Icons.person,
            color: primaryColor,
          ),
        ],
        backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            getInputTxt(context, "Store"),
            getInputTxt(context, "Address"),
            Text("Enter In a Store And Address"),
            getProfileBar(context, "Michael Jackson", 16.50),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: myMap.build(context),
            ),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
