import 'package:flutter/material.dart';
import 'package:ultiplay/screens/current_game.dart';
import 'package:ultiplay/screens/home.dart';
import 'package:ultiplay/screens/new_game.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: Home(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      routes: {
        Home.routeName: (context) => Home(),
        NewGame.routeName: (context) => NewGame(),
        CurrentGame.routeName: (context) => CurrentGame(),
      },
    );
  }
}
