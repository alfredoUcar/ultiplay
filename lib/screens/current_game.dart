import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ultiplay/extensions/enum.dart';
import 'package:ultiplay/extensions/string.dart';
import 'package:ultiplay/models/checkpoint.dart';
import 'package:ultiplay/models/game.dart';

class CurrentGameArguments {
  void Function() onFinish;
  Game game;

  CurrentGameArguments(this.onFinish, this.game);
}

class CurrentGame extends StatefulWidget {
  static const routeName = 'current-game';

  @override
  State<StatefulWidget> createState() {
    return _CurrentGame();
  }
}

class _CurrentGame extends State<CurrentGame>
    with SingleTickerProviderStateMixin {
  late Game _game;
  late final Ticker _ticker;
  late Duration _elapsed;
  late Function() _finishGame;

  @override
  void initState() {
    super.initState();
    _ticker = this.createTicker((elapsed) {
      var _newElapsed = _game.getElapsed();
      if (_newElapsed.inSeconds > _elapsed.inSeconds) {
        // just update timer once per second
        setState(() {
          _elapsed = _newElapsed;
        });
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenArguments =
        ModalRoute.of(context)!.settings.arguments as CurrentGameArguments;
    _game = screenArguments.game;
    _elapsed = _game.getElapsed();
    _finishGame = screenArguments.onFinish;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Game"),
        ),
        body: Column(
          children: [
            gameStatus(),
            Divider(thickness: 1.8),
            timeline(),
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
                Timestamp(elapsed: _elapsed),
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

  Widget timeline() {
    if (_game.checkpoints.isEmpty) {
      return Container(
        child: Expanded(child: Center(child: Text('No actions performed yet'))),
      );
    } else {
      return Container(
        child: Expanded(
          child: ListView.separated(
              shrinkWrap: true,
              reverse: true,
              itemBuilder: (context, index) {
                var checkpoint = _game.checkpoints[index];
                var elapsed = _game.getElapsed(at: checkpoint.timestamp);
                return ListTile(
                  title: Text(checkpoint.toString()),
                  leading: Timestamp(elapsed: elapsed),
                );
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
    } else if (_game.isOnCall()) {
      return callStep();
    } else {
      return playOnStep();
    }
  }

  Widget callStep() {
    return Container(
      color: Colors.blue[50],
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              'On Call',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('From'),
                    Radio(
                        value: _game.yourTeamName,
                        groupValue: _game.callInProgress?.team,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _game.callInProgress?.team = value;
                            });
                          }
                        }),
                    Text(_game.yourTeamName),
                    Radio(
                        value: _game.opponentTeamName,
                        groupValue: _game.callInProgress?.team,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _game.callInProgress?.team = value;
                            });
                          }
                        }),
                    Text(_game.opponentTeamName),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Call type'),
                    DropdownButton<CallType>(
                        onChanged: (CallType? value) {
                          setState(() {
                            _game.callInProgress!.callType = value;
                          });
                        },
                        value: _game.callInProgress!.callType,
                        items: CallType.values
                            .map((e) => DropdownMenuItem(
                                  child: Text(
                                      e.name.capitalize().replaceAll('_', ' ')),
                                  value: e,
                                ))
                            .toList()),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _game.callInProgress!.callType = null;
                          });
                        },
                        icon: Icon(Icons.clear)),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _game.callAccepted();
                      });
                    },
                    style: ButtonStyle(),
                    child: Text('Accepted')),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _game.callContested();
                      });
                    },
                    style: ButtonStyle(),
                    child: Text('Contested')),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _game.discardCall();
                      });
                    },
                    style: ButtonStyle(),
                    child: Text('Cancel')),
              ],
            ),
          ), // actions
        ],
      ),
    );
  }

  Widget pullStep() {
    var team = _game.onDefense() ? _game.yourTeamName : _game.opponentTeamName;
    var sideMessage = _game.yourTeamSide == FieldSide.left
        ? "Your team plays on left side"
        : "Your team plays on right side";
    String? genderRatioMessage;

    if (_game.isMixed()) {
      if (_game.appliesGenderRuleB()) {
        genderRatioMessage = _game.yourTeamChoosesGender()
            ? 'Your team chooses gender ratio'
            : 'Opponent team chooses gender ratio';
      } else if (_game.appliesGenderRuleA()) {
        genderRatioMessage =
            "Playing with ${_game.getRequiredWomenOnLine()} women";
      }
    }

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
          ),
          if (genderRatioMessage != null)
            Text(
              genderRatioMessage,
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
                ElevatedButton(onPressed: finishGame, child: Text('Finish')),
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
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _game.call();
                      });
                    },
                    style: ButtonStyle(),
                    child: Text('Call')),
                ElevatedButton(onPressed: finishGame, child: Text('Finish')),
              ],
            ),
          ), // actions
        ],
      ),
    );
  }

  void finishGame() {
    _finishGame();
    Navigator.of(context).pop();
  }
}

class Timestamp extends StatelessWidget {
  const Timestamp({
    Key? key,
    required Duration elapsed,
  })  : _elapsed = elapsed,
        super(key: key);

  final Duration _elapsed;

  @override
  Widget build(BuildContext context) {
    var minDigits = 2;
    var padding = '0';
    var minutes = _elapsed.inMinutes.toString().padLeft(minDigits, padding);
    var seconds =
        _elapsed.inSeconds.remainder(60).toString().padLeft(minDigits, padding);
    return Column(
      children: [
        Icon(Icons.watch_later_outlined),
        Text("$minutes:$seconds"),
      ],
    );
  }
}
