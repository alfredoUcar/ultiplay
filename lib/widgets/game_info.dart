import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/models/entities/checkpoint_entry.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/states/played_games.dart';
import 'package:ultiplay/widgets/timer.dart';

class GameInfo extends StatelessWidget {
  const GameInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayedGames>(
      builder: (context, playedGames, child) {
        var game = playedGames.selectedGame as Game;
        var checkpoints = playedGames.selectedGameCheckpoints;
        checkpoints.sort(mostRecentFirst);
        var teamNameStyle = TextStyle(fontSize: 18);
        var scoreBoardStyle =
            TextStyle(fontSize: 40, fontWeight: FontWeight.bold);
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      game.yourTeamName,
                      style: teamNameStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      game.scoreboard,
                      style: scoreBoardStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      game.opponentTeamName,
                      style: teamNameStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              Divider(thickness: 1.8),
              Expanded(
                child: ListView.separated(
                    shrinkWrap: true,
                    reverse: true,
                    itemBuilder: (context, index) {
                      var checkpoint = checkpoints[index];
                      return ListTile(
                        title: Text(checkpoint.description),
                        leading:
                            Timer(time: game.getTime(at: checkpoint.timestamp)),
                      );
                    },
                    separatorBuilder: (_, __) => Divider(),
                    itemCount: checkpoints.length),
              ),
            ],
          ),
        );
      },
    );
  }

  int mostRecentFirst(CheckpointEntry a, CheckpointEntry b) {
    return a.timestamp.compareTo(b.timestamp);
  }
}
