import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        child: Text("Google Sign-in"),
                        onPressed: () => googleSignIn(),
                        color: Colors.blue,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        child: Text("Google Sign-Out"),
                        onPressed: () => _logout(),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<FirebaseUser> googleSignIn() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignin.signIn();
    GoogleSignInAuthentication googleSignInAuthentication  = await googleSignInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(accessToken: googleSignInAuthentication.accessToken, idToken: googleSignInAuthentication.idToken);
    FirebaseUser user = await _auth.signInWithCredential(credential);
    print("User is ${user.displayName}");
    setState(() {
      _imageUrl = user.photoUrl;
    });
  }
}
