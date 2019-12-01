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
        child: user == null
            ? Center(
                child: RaisedButton(
                  color: Styles.primaryYellow,
                  child: Text("Login"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              )
            : Column(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Styles.primaryYellow,
                      child: Center(
                        child: Text(
                          user.userEmail,
                          style: Styles.header3TextStyle,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Container(
                        height: 70,
                        child: FlatButton(
//                      color: Colors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SavedItems(user: user)),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.bookmark_border,
                                color: Styles.blueGrey,
                              ),
                              Text(
                                "  Saved items",
                                style: Styles.header2TextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
