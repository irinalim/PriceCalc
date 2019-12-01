import 'package:PriceCalc/app_localizations.dart';
import 'package:PriceCalc/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:PriceCalc/Components/Home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Components/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Components/SavedItems.dart';

void main() async {
  Widget _defaultScreen = Home();

  runApp(MaterialApp(
    title: 'PriceCalc',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    supportedLocales: [Locale('ru', 'RU'), Locale('en', 'US')],
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    localeResolutionCallback: (locale, supportedLocales) {
      if (locale == null) {
        return supportedLocales.first;
      }
      // Check if the current device locale is supported
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode &&
            supportedLocale.countryCode == locale.countryCode) {
          return supportedLocale;
        }
      }
      // If the locale of the device is not supported, use the first one
      // from the list (English, in this case).
      return supportedLocales.first;
    },
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
