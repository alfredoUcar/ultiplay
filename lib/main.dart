import 'package:flutter/material.dart';
import 'package:ultiplay/screens/home.dart';
import 'package:ultiplay/screens/new_game.dart';

void main() {
  runApp(Ultiplay());
}

class Ultiplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultiplay',
      home: Home(),
      routes: {
        Home.routeName: (context) => Home(),
        NewGame.routeName: (context) => NewGame(),
      },
    );
  }
}
