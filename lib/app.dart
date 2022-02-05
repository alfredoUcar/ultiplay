import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/screens/game_detail.dart';
import 'package:ultiplay/screens/reset_password.dart';
import 'package:ultiplay/states/config.dart' as States;
import 'package:ultiplay/states/current_game.dart' as States;
import 'package:ultiplay/states/played_games.dart' as States;
import 'package:ultiplay/states/session.dart' as States;
import 'package:ultiplay/screens/current_game.dart';
import 'package:ultiplay/screens/home.dart';
import 'package:ultiplay/screens/new_game.dart';
import 'package:ultiplay/screens/sign_in.dart';
import 'package:ultiplay/screens/sign_up.dart';
import 'package:ultiplay/screens/verify_email.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class App {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await FirebaseAnalytics.instance.logAppOpen();
    await MobileAds.instance.initialize();
  }

  static Widget create(String environment) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => States.Session()),
        ChangeNotifierProvider(create: (context) => States.Config(environment)),
        ChangeNotifierProvider(create: (context) => States.CurrentGame()),
        ChangeNotifierProvider(create: (context) {
          var state = States.PlayedGames();
          var user = Provider.of<States.Session>(context, listen: false).user;
          if (user != null) {
            state.fetch(user.id);
          }
          return state;
        }),
      ],
      child: Ultiplay(),
    );
  }
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

    return Consumer<States.Session>(builder: (context, session, child) {
      return MaterialApp(
        title: 'Ultiplay',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
        ],
        routes: {
          SignIn.routeName: (context) => SignIn(),
          SignUp.routeName: (context) => SignUp(),
          ResetPassword.routeName: (context) => ResetPassword(),
        },
        onGenerateRoute: (settings) {
          if (session.user == null) {
            return MaterialPageRoute(
                settings: settings, builder: (context) => SignIn());
          } else if (!session.user!.emailVerified) {
            return MaterialPageRoute(
                settings: settings, builder: (context) => VerifyEmail());
          } else {
            switch (settings.name) {
              case NewGame.routeName:
                return MaterialPageRoute(
                    settings: settings, builder: (context) => NewGame());
              case CurrentGame.routeName:
                return MaterialPageRoute(
                    settings: settings, builder: (context) => CurrentGame());
              case GameDetail.routeName:
                return MaterialPageRoute(
                    settings: settings, builder: (context) => GameDetail());
              default:
                return MaterialPageRoute(
                    settings: settings, builder: (context) => Home());
            }
          }
        },
      );
    });
  }
}
