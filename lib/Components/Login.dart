import 'package:PriceCalc/Components/Home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:PriceCalc/Models/user.dart';
import 'package:PriceCalc/Components/Register.dart';
import 'package:PriceCalc/utils/styles.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _loginFormKey = GlobalKey<FormState>();
  User user = User("", "", "");
  FirebaseUser currentUser;
  String _loginAlert = "";
  bool _isInAsyncCall = false;

  void _showProgressIndicator() {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _isInAsyncCall = true;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((currentUser) {
      if (currentUser != null) {
        var router = new MaterialPageRoute(builder: (BuildContext context) {
          return Home();
        });
        Navigator.of(context).push(router);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'),
          backgroundColor: Styles.primaryBlue),
      body: ModalProgressHUD(
        color: Colors.white,
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Styles.primaryBlue),
        ),
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 500,
                      child: Form(
                        key: _loginFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.email),
                                hintText: 'Введите свой email',
                                labelText: 'Email',
                              ),
                              onSaved: (value) => user.userEmail = value.trim(),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Введите email';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.lock),
                                hintText: 'Введите свой пароль',
                                labelText: 'Пароль',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Введите пароль';
                                }
                                return null;
                              },
                              onSaved: (value) => user.password = value.trim(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        handleSignInUser();
                      },
                      child: Text("Login user"),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      },
                      child: Text("Register"),
                    ),
                    RaisedButton(
                      child: Text("Google Sign-in"),
                      onPressed: () => signInWithGoogle(),
                      color: Colors.blue,
                    ),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Padding(
//                      padding: const EdgeInsets.all(8.0),
//                      child: FlatButton(
//                        child: Text("Google Sign-in"),
//                        onPressed: () => signInWithGoogle(),
//                        color: Colors.blue,
//                      ),
//                    ),
//                  ],
//                ),
                    Text("User is ${user.userId}"),
                    Text(
                      _loginAlert,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future handleSignInUser() async {
    if (_loginFormKey.currentState.validate()) {
      _loginFormKey.currentState.save();
      _loginFormKey.currentState.reset();
      try {
        _showProgressIndicator();
        final email = user.userEmail;
        final password = user.password;
        debugPrint("Email and password are $email + $password");
        FirebaseUser currentUser = await _signInUser(email, password);
        setState(() {
          user = User.fromSnapshot(currentUser);
        });
        var router = new MaterialPageRoute(builder: (BuildContext context) {
          return Home();
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

  Future _signInUser(email, password) async {
    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
    return user;
  }

  Future<String> signInWithGoogle() async {
    try {
      _showProgressIndicator();
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
      final FirebaseUser fbuser = authResult.user;

      assert(!fbuser.isAnonymous);
      assert(await fbuser.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      print(currentUser.uid + currentUser.displayName);
      assert(fbuser.uid == currentUser.uid);
      setState(() {
        user = User.fromSnapshot(currentUser);
      });
      var router = new MaterialPageRoute(builder: (BuildContext context) {
        return Home();
      });
      Navigator.of(context).push(router);
      return 'signInWithGoogle succeeded: $user';
    } on PlatformException catch (e) {
      print(e);
      _loginAlert = e.message;
      _isInAsyncCall = false;
    }
  }
}
