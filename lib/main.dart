import 'package:flutter/material.dart';
import 'package:PriceCalc/Components/Home.dart';
import 'Components/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Components/SavedItems.dart';

void main () async {
  Widget _defaultScreen = Login();

  FirebaseAuth.instance.currentUser().then((currentUser) {
    if (currentUser != null) {
      _defaultScreen = Home();
    }
  });

  runApp(MaterialApp(
    title: 'PriceApp',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: _defaultScreen,
    routes: <String, WidgetBuilder>{
      // Set routes for using the Navigator.
      '/home': (BuildContext context) => Home(),
      '/login': (BuildContext context) => Login(),
      '/saved': (BuildContext context) => SavedItems(),
    },
  ));
}

//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'PriceApp',
//      theme: ThemeData(
//        primarySwatch: Colors.blue,
//      ),
//      home: _defaultScreen,
//      routes: <String, WidgetBuilder>{
//        // Set routes for using the Navigator.
//        '/home': (BuildContext context) => Home(),
//        '/login': (BuildContext context) => Login()
//      },
//    );
//  }
//}
