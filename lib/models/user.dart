class User {
  String _id;
  String? _email;
  bool _emailVerified;

  User(this._id, this._email, this._emailVerified);

  String get id => _id;
  String? get email => _email;
  bool get emailVerified => _emailVerified;
}
