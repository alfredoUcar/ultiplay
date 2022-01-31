import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/extensions/enum.dart';
import 'package:ultiplay/extensions/string.dart';
import 'package:ultiplay/models/checkpoint.dart';
import 'package:ultiplay/states/current_game.dart';

class CallStep extends StatelessWidget {
  const CallStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bodyTextStyle = TextStyle(fontSize: 20);
    return Consumer<CurrentGame>(
      child: Expanded(
        child: Padding(
          padding: EdgeInsets.only(top: 25.0),
          child: Text(
            'On Call',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      builder: (context, game, child) => Column(
        children: [
          child as Widget,
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('From', style: bodyTextStyle),
                      Radio(
                          value: game.yourTeamName,
                          groupValue: game.callInProgress?.team,
                          onChanged: (String? value) {
                            if (value != null) {
                              game.callInProgress?.team = value;
                            }
                          }),
                      Text(game.yourTeamName, style: bodyTextStyle),
                      Radio(
                          value: game.opponentTeamName,
                          groupValue: game.callInProgress?.team,
                          onChanged: (String? value) {
                            if (value != null) {
                              game.callInProgress?.team = value;
                            }
                          }),
                      Text(game.opponentTeamName, style: bodyTextStyle),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Call type', style: bodyTextStyle),
                      DropdownButton<CallType>(
                          onChanged: (CallType? value) {
                            game.callInProgress!.callType = value;
                          },
                          value: game.callInProgress!.callType,
                          items: CallType.values
                              .map((e) => DropdownMenuItem(
                                    child: Text(
                                      e.name.capitalize().replaceAll('_', ' '),
                                      style: bodyTextStyle,
                                    ),
                                    value: e,
                                  ))
                              .toList()),
                      IconButton(
                          onPressed: () {
                            game.callInProgress!.callType = null;
                          },
                          icon: Icon(Icons.clear)),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      game.callAccepted();
                    },
                    style: ButtonStyle(),
                    child: Text('Accepted')),
                ElevatedButton(
                    onPressed: () {
                      game.callContested();
                    },
                    style: ButtonStyle(),
                    child: Text('Contested')),
                ElevatedButton(
                    onPressed: () {
                      game.discardCall();
                    },
                    style: ButtonStyle(),
                    child: Text('Cancel')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
