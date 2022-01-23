import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/states/played_games.dart';
import 'package:ultiplay/widgets/global_menu.dart';

class GameDetail extends StatelessWidget {
  static const routeName = 'game-detail';
  const GameDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ultiplay'),
      ),
      drawer: GlobalMenu(),
      body: Center(
        child: getGameDetailContent(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget getGameDetailContent(BuildContext context) {
    return Consumer<PlayedGames>(builder: (context, playedGames, child) {
      if (playedGames.fetching()) {
        return CircularProgressIndicator();
      }

      if (playedGames.selectedGame == null) {
        return Text('Could not load game details');
      }

      return Text(playedGames.selectedGame!.summary.title);
    });
  }
}
