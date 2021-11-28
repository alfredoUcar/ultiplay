import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ultiplay/models/game.dart';

class CurrentGame extends StatefulWidget {
  final Game game;

  CurrentGame(this.game);

  @override
  State<StatefulWidget> createState() {
    return _CurrentGame(game);
  }
}

class _CurrentGame extends State<CurrentGame>
    with SingleTickerProviderStateMixin {
  Game _game;
  late final Ticker _ticker;
  Duration _elapsed;

  _CurrentGame(this._game) : _elapsed = _game.getElapsed();

  @override
  void initState() {
    super.initState();
    // _ticker = this.createTicker((elapsed) {
    //   setState(() {
    //     _elapsed = _game.getElapsed();
    //   });
    // });
    // _ticker.start();
  }

  // @override
  // void dispose() {
  //   _ticker.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Game"),
        ),
        body: Column(
          children: [
            gameStatus(),
            Divider(
              thickness: 1.8,
            ),
            gameTimeline(),
          ],
        ));
  }

  Widget gameStatus() {
    var teamNameStyle = TextStyle(fontSize: 18);
    var scoreBoardStyle = TextStyle(fontSize: 40, fontWeight: FontWeight.bold);
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Text(
            _game.yourTeamName,
            style: teamNameStyle,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "12-11", // TODO: replace with actual score
                  style: scoreBoardStyle,
                ),
                Text(
                    "${_elapsed.inMinutes}:${_elapsed.inSeconds.remainder(60)}"),
              ],
            ),
          ),
          Text(
            _game.opponentTeamName,
            style: teamNameStyle,
          ),
        ],
      ),
    );
  }

  Widget gameTimeline() {
    List<String> entries = [
      'a',
      'b',
      'c',
      'd',
      'e',
      'f',
      'g',
      'h',
      'i',
    ]; // TODO: replace with game entries

    if (entries.isEmpty) {
      return Container(
        child: Text('No actions performed yet'),
      );
    } else {
      return Container(
        child: Expanded(
          child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(title: Text('Item $index: ${entries[index]}'));
              },
              separatorBuilder: (_, __) => Divider(),
              itemCount: entries.length),
        ),
      );
    }
  }
}
