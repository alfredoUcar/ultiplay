import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/states/current_game.dart';

class PullStep extends StatelessWidget {
  const PullStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGame>(
      child: Expanded(
        child: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Pull time',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      builder: (context, game, child) {
        var team = game.onDefense() ? game.yourTeamName : game.opponentTeamName;
        var sideMessage = game.yourTeamSide == FieldSide.left
            ? "Your team plays on left side"
            : "Your team plays on right side";
        String? genderRatioMessage;

        if (game.isMixed()) {
          if (game.appliesGenderRuleB()) {
            genderRatioMessage = game.yourTeamChoosesGender()
                ? 'Your team chooses gender ratio'
                : 'Opponent team chooses gender ratio';
          } else if (game.appliesGenderRuleA()) {
            genderRatioMessage =
                "Playing with ${game.getRequiredWomenOnLine()} women";
          }
        }

        return Column(
          children: [
            child as Widget,
            Expanded(
              child: Column(
                children: [
                  if (genderRatioMessage != null) Text(genderRatioMessage),
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
                          game.pull();
                        },
                        style: ButtonStyle(),
                        child: Text('Done')),
                    Visibility(
                      visible: !game.isHalftimeReached(),
                      child: ElevatedButton(
                          onPressed: () {
                            game.halfTime();
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
      },
    );
  }
}
