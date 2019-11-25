import 'package:PriceCalc/Components/SavedItems.dart';
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
            Expanded(
              flex: 1,
              child: Center(
                child: Text(user.userEmail, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
              ),
            ),
            Expanded(
                flex: 3,
                child: Center(
                    child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SavedItems(user: user)),
                    );
                  },
                  child: Text("Saved items"),
                ))),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: RaisedButton(
                  onPressed: () async {
                    _auth.signOut();
                    await _googleSignIn.signOut();
                    print("User Sign Out");
                    Navigator.pushReplacementNamed(context, '/login');
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
