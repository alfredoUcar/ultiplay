import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ultiplay/screens/current_game.dart';
import 'package:ultiplay/screens/home.dart';
import 'package:ultiplay/screens/new_game.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ultiplay/screens/sign_in.dart';
import 'package:ultiplay/screens/sign_up.dart';
import 'package:ultiplay/screens/verify_email.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAnalytics.instance.logAppOpen();
  runApp(Ultiplay());
}

class Ultiplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var lightTheme = Theme.of(context).copyWith(
      brightness: Brightness.light,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Colors.deepPurple[700],
            secondary: Colors.purple,
          ),
    );
    lightTheme = lightTheme.copyWith(
      bottomAppBarTheme: lightTheme.bottomAppBarTheme.copyWith(
        color: lightTheme.colorScheme.primary,
      ),
    );

    var darkTheme = Theme.of(context).copyWith(
      brightness: Brightness.dark,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Colors.deepPurple[700],
            secondary: Colors.purple,
          ),
    );
    darkTheme = lightTheme.copyWith(
      bottomAppBarTheme: lightTheme.bottomAppBarTheme.copyWith(
        color: lightTheme.colorScheme.primary,
      ),
    );

    return MaterialApp(
      title: 'Ultiplay',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      routes: {
        SignIn.routeName: (context) => SignIn(),
        SignUp.routeName: (context) => SignUp(),
      },
      onGenerateRoute: (settings) {
        if (FirebaseAuth.instance.currentUser == null) {
          return MaterialPageRoute(
              settings: settings, builder: (context) => SignIn());
        } else if (!FirebaseAuth.instance.currentUser!.emailVerified) {
          return MaterialPageRoute(
              settings: settings, builder: (context) => VerifyEmail());
        } else {
          FirebaseAnalytics.instance.logScreenView(screenName: settings.name);
          switch (settings.name) {
            case NewGame.routeName:
              return MaterialPageRoute(
                  settings: settings, builder: (context) => NewGame());
            case CurrentGame.routeName:
              return MaterialPageRoute(
                  settings: settings, builder: (context) => CurrentGame());
            default:
              return MaterialPageRoute(
                  settings: settings, builder: (context) => Home());
          }
        }
      },
    );
  }
}
