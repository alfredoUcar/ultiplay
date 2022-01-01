import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/states/current_game.dart';

class PlayOnStep extends StatelessWidget {
  const PlayOnStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGame>(
      child: Expanded(
        child: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Play On',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      builder: (context, game, child) {
        var team = game.onOffense() ? game.yourTeamName : game.opponentTeamName;
        return Column(
          children: [
            child as Widget,
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
                        game.goal();
                      },
                      style: ButtonStyle(),
                      child: Text('Goal')),
                  ElevatedButton(
                      onPressed: () {
                        game.turnover();
                      },
                      style: ButtonStyle(),
                      child: Text('Turnover')),
                  ElevatedButton(
                      onPressed: () {
                        game.call();
                      },
                      style: ButtonStyle(),
                      child: Text('Call')),
                ],
              ),
            ), // actions
          ],
        );
      },
    );
  }
}
