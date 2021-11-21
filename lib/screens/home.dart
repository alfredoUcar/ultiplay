import 'package:flutter/material.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/screens/new_game.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  Game? _currentGame;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ultiplay'),
        ),
        body: Center(
            child: OutlinedButton(
                child: _currentGame != null
                    ? Text('Continue game')
                    : Text('New game'),
                onPressed: () {
                  openNewGameForm(context);
                })));
  }

  void openNewGameForm(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NewGame(
              onStart: (Game? game) {
                setState(() {
                  _currentGame = game;
                });
              },
            )));
  }
}
