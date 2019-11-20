class User {
  String userId;
  String userName;
  String userEmail;
  String password;

  User(this.userName, this.userEmail, this.password,
      {this.userId});
}