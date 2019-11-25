import 'package:PriceCalc/Models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:PriceCalc/utils/styles.dart';
import 'package:google_sign_in/google_sign_in.dart';

Widget homeDrawer(User user, context) {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  return Drawer(
    child: SafeArea(
      child: Container(
        color: Styles.primaryYellow,
        child: Column(
          children: <Widget>[
            Expanded(flex: 3,
                child: Center(
                    child: Text(user.userEmail))),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: RaisedButton(
                  onPressed: () async {
                    _auth.signOut();
                    await _googleSignIn.signOut();
                    print("User Sign Out");
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  color: Styles.lightGrey,
                  child: new Text(
                    "Выйти",
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
