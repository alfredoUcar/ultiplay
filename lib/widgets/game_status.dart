import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/states/current_game.dart';
import 'package:ultiplay/widgets/timer.dart';

class GameStatus extends StatelessWidget {
  const GameStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGame>(
      builder: (context, game, child) {
        var teamNameStyle = TextStyle(fontSize: 18);
        var scoreBoardStyle =
            TextStyle(fontSize: 40, fontWeight: FontWeight.bold);
        return Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              game.onOffense()
                  ? Icon(Icons.circle, color: Colors.green)
                  : Icon(Icons.circle_outlined, color: Colors.grey[400]),
              SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Text(
                  game.yourTeamName,
                  style: teamNameStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      game.isHalftimeReached() ? 'Second half' : 'First Half',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      game.scoreboard,
                      style: scoreBoardStyle,
                    ),
                    Timer(time: game.getTime()),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  game.opponentTeamName,
                  style: teamNameStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 10),
              game.onDefense()
                  ? Icon(Icons.circle, color: Colors.green)
                  : Icon(Icons.circle_outlined, color: Colors.grey[400]),
            ],
          ),
        );
      },
    );
  }
}
