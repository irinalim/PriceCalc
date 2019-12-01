import 'package:PriceCalc/Components/Login.dart';
import 'package:PriceCalc/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:PriceCalc/Models/user.dart';
import '../app_localizations.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _registerFormKey = GlobalKey<FormState>();
  User user = User("", "", "");
  String _loginAlert = "";
  bool _isInAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate('register')),
        backgroundColor: Styles.primaryBlue,
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.shortestSide - 40,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 500,
                    child: Form(
                      key: _registerFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.email),
                              hintText: AppLocalizations.of(context).translate('enter_email'),
                              labelText: AppLocalizations.of(context).translate('enter_email'),
                            ),
                            onSaved: (value) => user.userEmail = value.trim(),
                            validator: (value) {
                              if (value.isEmpty) {
                                return AppLocalizations.of(context).translate('enter_email');
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              hintText: AppLocalizations.of(context).translate('create_password'),
                              labelText: AppLocalizations.of(context).translate('create_password'),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return AppLocalizations.of(context).translate('create_password');
                              }
                              return null;
                            },
                            onSaved: (value) => user.password = value.trim(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: RaisedButton(
                      onPressed: () => handleCreateUser(),
                      child: Text(AppLocalizations.of(context).translate('register')),
                      color: Styles.primaryYellow,
                    ),
                  ),
//                  Text("User is ${user.userId}"),
                  Text(
                    _loginAlert,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future handleCreateUser() async {
    if (_registerFormKey.currentState.validate()) {
      _registerFormKey.currentState.save();
      _registerFormKey.currentState.reset();
      try {
        final email = user.userEmail;
        final password = user.password;
        debugPrint("Email and password are $email + $password");
        FirebaseUser currentUser = await _createUser(email, password);
        setState(() {
          user.userEmail = currentUser.email;
          user.userName = currentUser.displayName;
          user.userId = currentUser.uid;
        });
        var router = new MaterialPageRoute(builder: (BuildContext context) {
          return Login();
        });
        Navigator.of(context).push(router);
        return currentUser;
      } on PlatformException catch (e) {
        print("platform exception");
        print(e.toString());
        setState(() {
          _loginAlert = e.message;
          _isInAsyncCall = false;
        });
      } on Exception catch (e) {
        print("exception");
        print(e.toString());
        setState(() {
          _loginAlert = e.toString();
          _isInAsyncCall = false;
        });
      }
    }
  }

  Future _createUser(email, password) async {
    final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
    return user;
  }

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
      await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult =
      await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      print(currentUser.uid + currentUser.displayName);
      assert(user.uid == currentUser.uid);
      return 'signInWithGoogle succeeded: $user';
    } on PlatformException catch (e) {
      print(e);
    }
  }

}
