import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/screens/current_game.dart';
import 'package:ultiplay/screens/new_game.dart';
import 'package:ultiplay/states/current_game.dart' as States;
import 'package:ultiplay/states/played_games.dart' as States;
import 'package:ultiplay/widgets/global_menu.dart';
import 'package:ultiplay/widgets/played_games.dart';

class Home extends StatelessWidget {
  static const routeName = 'home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ultiplay'),
      ),
      drawer: GlobalMenu(),
      body: Center(
        child: (Provider.of<States.PlayedGames>(context).isEmpty())
            ? Text('Press "+" button to start your first game')
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                PlayedGames(),
              ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Consumer<States.CurrentGame>(
        builder: (context, currentGame, child) => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: !currentGame.isEmpty() && !currentGame.finished(),
              child: FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.play_arrow),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CurrentGame.routeName);
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
                  Navigator.of(context).pushNamed(NewGame.routeName);
                }),
          ],
        ),
      ),
    );
  }
}
