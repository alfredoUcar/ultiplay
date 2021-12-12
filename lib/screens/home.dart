import 'package:flutter/material.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/screens/current_game.dart';
import 'package:ultiplay/screens/new_game.dart';

class Home extends StatefulWidget {
  static const routeName = 'home';

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  Game? _currentGame;
  List<Game> _playedGames = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ultiplay'),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Visibility(
              visible: _currentGame != null,
              child: OutlinedButton(
                  child: Text('Continue game'),
                  onPressed: () {
                    openCurrentGame(context);
                  }),
            ),
            OutlinedButton(
                child: Text('New game'),
                onPressed: () {
                  openNewGameForm(context);
                })
          ]),
        ));
  }

  void openNewGameForm(BuildContext context) {
    Navigator.of(context).pushNamed(NewGame.routeName,
        arguments: NewGameArguments(startGameHandler, finishGameHandler));
  }

  startGameHandler(Game game) {
    setState(() {
      _currentGame = game;
      _currentGame!.start();
    });
  }

  finishGameHandler() {
    if (_currentGame != null) {
      setState(() {
        _currentGame!.finish();
        _playedGames.add(_currentGame as Game);
        _currentGame = null;
      });
    }
  }

  void openCurrentGame(BuildContext context) {
    Navigator.of(context).pushNamed(CurrentGame.routeName,
        arguments:
            CurrentGameArguments(finishGameHandler, _currentGame as Game));
  }
}
