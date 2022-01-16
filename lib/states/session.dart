import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:ultiplay/models/user.dart';

class UserNotFoundException implements Exception {}

class WeakPasswordException implements Exception {
  String message;
  WeakPasswordException(this.message);
}

class EmailAlreadyInUseException implements Exception {}

class WrongPasswordException implements Exception {}

class UnexpectedException implements Exception {}

class Session extends ChangeNotifier {
  User? user;
  bool _authenticating = false;
  bool _registering = false;

  Session() {
    _updateUser(Auth.FirebaseAuth.instance.currentUser);
    Auth.FirebaseAuth.instance.userChanges().listen(_updateUser);
  }

  void _updateUser(Auth.User? authUser) async {
    if (authUser == null) {
      user = null;
      FirebaseAnalytics.instance.setUserId(id: null);
      FirebaseCrashlytics.instance.setUserIdentifier('');
    } else {
      user = User(authUser.uid, authUser.email, authUser.emailVerified);
      FirebaseCrashlytics.instance.setUserIdentifier(authUser.uid);
      FirebaseAnalytics.instance.setUserId(id: authUser.uid);
      FirebaseAnalytics.instance
          .setUserProperty(name: 'email', value: authUser.email);
    }
    notifyListeners();
  }

  Future<void> reloadUser() async {
    Auth.FirebaseAuth.instance.currentUser!.reload();
  }

  bool get authenticating => _authenticating;
  bool get registering => _registering;

  Future<void> sendEmailVerification() async {
    Auth.FirebaseAuth.instance.currentUser!.sendEmailVerification();
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    try {
      _authenticating = true;
      notifyListeners();

      await Auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on Auth.FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (error.code == 'wrong-password') {
        throw WrongPasswordException();
      } else {
        FirebaseCrashlytics.instance.log(
            'Unexpected error during log in: [${error.code}] ${error.message}');
        throw UnexpectedException();
      }
    } finally {
      _authenticating = false;
      notifyListeners();
    }
    FirebaseAnalytics.instance.logLogin(loginMethod: 'email');
  }

  void logOut() {
    Auth.FirebaseAuth.instance.signOut();
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      _registering = true;
      notifyListeners();

      await Auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on Auth.FirebaseAuthException catch (error) {
      if (error.code == 'weak-password') {
        print(error.message);
        throw WeakPasswordException(
            error.message ?? 'The password provided is too weak');
      } else if (error.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else {
        FirebaseCrashlytics.instance.log(
            'Unexpected error during sign up: [${error.code}] ${error.message}');
        throw UnexpectedException();
      }
    } finally {
      _registering = false;
      notifyListeners();
    }
    FirebaseAnalytics.instance.logSignUp(signUpMethod: 'email');
  }
}
