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
            Divider(thickness: 1.8),
            gameTimeline(),
            currentStep(),
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
          _game.onOffense()
              ? Icon(Icons.circle, color: Colors.green)
              : Icon(Icons.circle_outlined, color: Colors.grey[400]),
          Text(
            _game.yourTeamName,
            style: teamNameStyle,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "${_game.yourScore} - ${_game.opponentScore}",
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
          _game.onDefense()
              ? Icon(Icons.circle, color: Colors.green)
              : Icon(Icons.circle_outlined, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget gameTimeline() {
    if (_game.checkpoints.isEmpty) {
      return Container(
        child: Expanded(child: Center(child: Text('No actions performed yet'))),
      );
    } else {
      return Container(
        child: Expanded(
          child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Text(_game.checkpoints[index].toString()));
              },
              separatorBuilder: (_, __) => Divider(),
              itemCount: _game.checkpoints.length),
        ),
      );
    }
  }

  Widget currentStep() {
    if (_game.isPullTime()) {
      return pullStep();
    } else {
      return playOnStep();
    }
  }

  Widget pullStep() {
    var team = _game.onDefense() ? _game.yourTeamName : _game.opponentTeamName;
    var sideMessage = _game.yourTeamSide == FieldSide.left
        ? "Your team plays on left side"
        : "Your team plays on right side";
    return Container(
      color: Colors.blue[50],
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              'Pull time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ), // title
          Text(
            sideMessage,
            style: TextStyle(color: Colors.grey),
          ), // description
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text('$team throws pull'),
          ), // description
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _game.pull();
                      });
                    },
                    style: ButtonStyle(),
                    child: Text('Done')),
                ElevatedButton(onPressed: null, child: Text('Finish')),
              ],
            ),
          ), // actions
        ],
      ),
    );
  }

  Widget playOnStep() {
    var team = _game.onOffense() ? _game.yourTeamName : _game.opponentTeamName;
    return Container(
      color: Colors.blue[50],
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              'Play On',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ), // title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text('$team on offense'),
          ), // description
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _game.goal();
                      });
                    },
                    style: ButtonStyle(),
                    child: Text('Goal')),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _game.turnover();
                      });
                    },
                    style: ButtonStyle(),
                    child: Text('Turnover')),
                ElevatedButton(onPressed: null, child: Text('Finish')),
              ],
            ),
          ), // actions
        ],
      ),
    );
  }
}
