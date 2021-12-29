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

class _CurrentGame extends State<CurrentGame> with TickerProviderStateMixin {
  late Game _game;
  late final Ticker _ticker;
  late String _time;
  late Function() _finishGame;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _ticker = this.createTicker((elapsed) {
      var newTime = _game.getTime();
      if (newTime != _time) {
        setState(() {
          _time = newTime;
        });
      }
    });
    _ticker.start();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenArguments =
        ModalRoute.of(context)!.settings.arguments as CurrentGameArguments;
    _game = screenArguments.game;
    _time = _game.getTime();
    _finishGame = screenArguments.onFinish;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Game"),
      ),
      floatingActionButtonLocation: (_tabController.index == 0)
          ? FloatingActionButtonLocation.endDocked
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: (_tabController.index == 0)
          ? FloatingActionButton(
              child: Icon(Icons.exit_to_app),
              onPressed: finishGame,
            )
          : FloatingActionButton(
              child: Icon(Icons.undo),
              onPressed: () {
                setState(() {
                  _game.undoLastCheckpoint();
                });
              },
            ),
      bottomNavigationBar: Material(
        color: Theme.of(context).colorScheme.primary,
        child: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          tabs: [
            Tab(
              icon: Icon(Icons.track_changes),
              text: 'Track',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'History',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          gameStatus(),
          Divider(thickness: 1.8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                currentStep(),
                timeline(),
              ],
            ),
          ),
        ],
      ),
    );
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
          SizedBox(width: 10),
          Text(
            _game.yourTeamName,
            style: teamNameStyle,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _game.isHalftimeReached() ? 'Second half' : 'First Half',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "${_game.yourScore} - ${_game.opponentScore}",
                  style: scoreBoardStyle,
                ),
                Timestamp(time: _game.getTime()),
              ],
            ),
          ),
          Text(
            _game.opponentTeamName,
            style: teamNameStyle,
          ),
          SizedBox(width: 10),
          _game.onDefense()
              ? Icon(Icons.circle, color: Colors.green)
              : Icon(Icons.circle_outlined, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget timeline() {
    if (_game.checkpoints.isEmpty) {
      return Center(child: Text('No actions performed yet'));
    } else {
      return ListView.separated(
          shrinkWrap: true,
          reverse: true,
          itemBuilder: (context, index) {
            var checkpoint = _game.checkpoints[index];
            var time = _game.getTime(at: checkpoint.timestamp);
            return ListTile(
              title: Text(checkpoint.toString()),
              leading: Timestamp(time: time),
            );
          },
          separatorBuilder: (_, __) => Divider(),
          itemCount: _game.checkpoints.length);
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
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              'On Call',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                child: Row(
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
              ),
              Expanded(
                child: Row(
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
                ),
              )
            ],
          ),
        ),
        Expanded(
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

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              'Pull time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ), // title
        Expanded(
          child: Column(
            children: [
              if (genderRatioMessage != null)
                Text(genderRatioMessage), // description
              Text(sideMessage),
              Text('$team throws pull')
            ],
          ),
        ),
        Expanded(
          child: Padding(
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
                Visibility(
                  visible: !_game.isHalftimeReached(),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _game.halfTime();
                        });
                      },
                      style: ButtonStyle(),
                      child: Text('Half Time')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget playOnStep() {
    var team = _game.onOffense() ? _game.yourTeamName : _game.opponentTeamName;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              'Play On',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ), // title
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text('$team on offense'),
          ),
        ), // description
        Expanded(
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
            ],
          ),
        ), // actions
      ],
    );
  }

  void finishGame() {
    _finishGame();
    Navigator.of(context).pop();
  }
}

class Timestamp extends StatelessWidget {
  final String time;

  const Timestamp({
    Key? key,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.watch_later_outlined),
        Text(time),
      ],
    );
  }
}
