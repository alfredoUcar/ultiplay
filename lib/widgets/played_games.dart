import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/states/played_games.dart' as States;
import 'package:ultiplay/states/session.dart' as States;

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
          child: RefreshIndicator(
            onRefresh: () async {
              var userId =
                  Provider.of<States.Session>(context, listen: false).user!.id;
              playedGames.fetch(userId);
            },
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                var playedGame = games[index];
                final DateFormat formatter = DateFormat.yMMMd().add_Hm();
                var trophyColor = playedGame.isVictory
                    ? Colors.amber.value
                    : Colors.grey.value;
                return Dismissible(
                  key: Key(playedGame.id as String),
                  background: Container(
                    color: Colors.red[400],
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red[400],
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                  ),
                  confirmDismiss: (DismissDirection direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text(
                              "Are you sure you wish to delete this game?"),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text("DELETE")),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("CANCEL"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    var userId =
                        Provider.of<States.Session>(context, listen: false)
                            .user!
                            .id;

                    var deleted = await playedGames.delete(
                        userId, playedGame.id as String);
                    if (deleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Game deleted')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('The game could not be deleted')));
                    }
                  },
                  child: ListTile(
                    leading:
                        Icon(Icons.emoji_events, color: Color(trophyColor)),
                    title: Text(
                        '${playedGame.yourTeamName} vs ${playedGame.opponentTeamName}'),
                    subtitle: Row(
                      children: [
                        Text(
                            formatter.format(playedGame.startedAt as DateTime)),
                      ],
                    ),
                    trailing: Text(
                      playedGame.scoreboard,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ),
                );
              },
              itemCount: playedGames.length,
              separatorBuilder: (BuildContext context, int index) => Divider(),
            ),
          ),
        ),
      );
    });
  }
}
