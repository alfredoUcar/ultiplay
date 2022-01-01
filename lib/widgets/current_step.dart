import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/states/current_game.dart';
import 'package:ultiplay/widgets/call_step.dart';
import 'package:ultiplay/widgets/play_on_step.dart';
import 'package:ultiplay/widgets/pull_step.dart';

class CurrentStep extends StatelessWidget {
  const CurrentStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGame>(
      builder: (context, game, child) {
        if (game.isPullTime()) {
          return PullStep();
        } else if (game.isOnCall()) {
          return CallStep();
        } else {
          return PlayOnStep();
        }
      },
    );
  }
}
