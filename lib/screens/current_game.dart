import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/screens/home.dart';
import 'package:ultiplay/states/current_game.dart' as States;
import 'package:ultiplay/states/played_games.dart' as States;
import 'package:ultiplay/states/session.dart' as States;
import 'package:ultiplay/widgets/current_step.dart';
import 'package:ultiplay/widgets/game_status.dart';
import 'package:ultiplay/widgets/timeline.dart';

class CurrentGame extends StatefulWidget {
  static const routeName = 'current-game';

  @override
  State<StatefulWidget> createState() {
    return _CurrentGame();
  }
}

class _CurrentGame extends State<CurrentGame> with TickerProviderStateMixin {
  late final Ticker _ticker;
  String? _time;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _ticker = this.createTicker((elapsed) {
      var newTime =
          Provider.of<States.CurrentGame>(context, listen: false).getTime();
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Game"),
      ),
      floatingActionButtonLocation: (_tabController.index == 0)
          ? FloatingActionButtonLocation.endDocked
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          Consumer3<States.Session, States.CurrentGame, States.PlayedGames>(
        builder: (context, session, currentGame, playedGames, child) =>
            (_tabController.index == 0)
                ? FloatingActionButton(
                    child: Icon(Icons.exit_to_app),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm"),
                            content: const Text(
                                "Are you sure you wish to finish this game?"),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                    currentGame.finish();
                                    currentGame.save(session.user!.id);
                                    playedGames.fetch(session.user!.id);

                                    Navigator.of(context)
                                        .pushReplacementNamed(Home.routeName);
                                  },
                                  child: const Text("FINISH")),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("CANCEL"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                : FloatingActionButton(
                    child: Icon(Icons.undo),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm"),
                            content: Text(
                                "Are you sure you wish to undo \"${currentGame.checkpoints.last.description}\"?"),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () async {
                                    currentGame.undoLastCheckpoint();
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text("UNDO")),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("CANCEL"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
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
          GameStatus(),
          Divider(thickness: 1.8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CurrentStep(),
                Timeline(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
