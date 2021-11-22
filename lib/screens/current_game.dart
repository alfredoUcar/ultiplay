import 'package:flutter/material.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/screens/new_game.dart';

class CurrentGame extends StatefulWidget {
  final Game game;

  CurrentGame(this.game);

  @override
  State<StatefulWidget> createState() {
    return _CurrentGame(game);
  }
}

class _CurrentGame extends State<CurrentGame> {
  Game _game;

  _CurrentGame(this._game);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text("${_game.yourTeamName} VS ${_game.opponentTeamName}"),
        ),
        body: Center(
            child: Text(
                "Playing ${_game.yourTeamName} VS ${_game.opponentTeamName}")));
  }
}
