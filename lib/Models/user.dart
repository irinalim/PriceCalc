import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class User {
  String userId;
  String userName;
  String userEmail;
  String password;

  User(this.userName, this.userEmail, this.password,
      {this.userId});

  User.fromSnapshot(FirebaseUser user)
      : userId = user.uid,
        userEmail = user.email,
        userName = user.displayName;
}
