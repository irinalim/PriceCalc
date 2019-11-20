import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:PriceCalc/Models/user.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _loginFormKey = GlobalKey<FormState>();
  User user = User("", "", "");
  String _loginAlert = "";
  bool _isInAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: ListView(
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
//                          controller: _emailController,
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
//                          controller: _passwordController,
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
                  onPressed: () => handleCreateUser(),
                  child: Text("Create user"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        child: Text("Google Sign-in"),
                        onPressed: () => signInWithGoogle(),
                        color: Colors.blue,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        child: Text("Google Sign-Out"),
                        onPressed: () => signOutGoogle(),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
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
    );
  }

  Future handleCreateUser() async {
    if (_loginFormKey.currentState.validate()) {
      _loginFormKey.currentState.save();
      _loginFormKey.currentState.reset();
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

  void signOutGoogle() async {
    await _googleSignIn.signOut();

    print("User Sign Out");
  }
}
