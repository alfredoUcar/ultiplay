import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/states/current_game.dart';
import 'package:ultiplay/widgets/timer.dart';

class Timeline extends StatelessWidget {
  const Timeline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentGame>(
      child: Center(child: Text('No actions performed yet')),
      builder: (context, game, child) {
        if (game.checkpoints.isEmpty) {
          return child as Widget;
        } else {
          return ListView.separated(
              shrinkWrap: true,
              reverse: true,
              itemBuilder: (context, index) {
                var checkpoint = game.checkpoints[index];
                var time = game.getTime(at: checkpoint.timestamp);
                return ListTile(
                  title: Text(checkpoint.toString()),
                  leading: Timer(time: time),
                );
              },
              separatorBuilder: (_, __) => Divider(),
              itemCount: game.checkpoints.length);
        }
      },
    );
  }
}
