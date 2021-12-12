import 'package:flutter/material.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/screens/current_game.dart';
import 'package:ultiplay/screens/new_game.dart';
import 'package:intl/intl.dart';

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
          PlayedGames(playedGames: _playedGames),
        ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: _currentGame != null,
            child: FloatingActionButton(
                heroTag: null,
                child: Icon(Icons.play_arrow),
                onPressed: () {
                  openCurrentGame(context);
                }),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.add),
              tooltip: 'New game',
              onPressed: () {
                openNewGameForm(context);
              }),
        ],
      ),
    );
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

class PlayedGames extends StatelessWidget {
  const PlayedGames({
    Key? key,
    required List<Game> playedGames,
  })  : _playedGames = playedGames,
        super(key: key);

  final List<Game> _playedGames;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            var playedGame = _playedGames[index];
            final DateFormat formatter = DateFormat.yMMMd().add_Hm();
            var trophyColor = playedGame.yourScore > playedGame.opponentScore
                ? Colors.amber.value
                : Colors.grey.value;
            return ListTile(
              leading: Icon(Icons.emoji_events, color: Color(trophyColor)),
              title: Text(
                  '${playedGame.yourTeamName} vs ${playedGame.opponentTeamName}'),
              subtitle: Row(
                children: [
                  Text(formatter.format(playedGame.startedAt as DateTime)),
                ],
              ),
              trailing: Text(
                '${playedGame.yourScore} - ${playedGame.opponentScore}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            );
          },
          itemCount: _playedGames.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
        ),
      ),
    );
  }
}
