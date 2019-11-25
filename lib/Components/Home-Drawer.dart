import 'package:PriceCalc/Models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget homeDrawer(User user) {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  return Drawer(
    child: SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              color: ,
            ),
          )
        ],
      ),
    ),
  );
}
