import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/states/played_games.dart' as States;

int mostRecentFirst(Game a, Game b) {
  return b.startedAt!.compareTo(a.startedAt as DateTime);
}

class PlayedGames extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<States.PlayedGames>(builder: (context, playedGames, child) {
      var games = playedGames.list;
      games.sort(mostRecentFirst);
      return Container(
        child: Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              var playedGame = games[index];
              final DateFormat formatter = DateFormat.yMMMd().add_Hm();
              var trophyColor =
                  playedGame.isVictory ? Colors.amber.value : Colors.grey.value;
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
                  playedGame.scoreboard,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              );
            },
            itemCount: playedGames.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
          ),
        ),
      );
    });
  }
}
