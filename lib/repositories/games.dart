import 'package:firebase_database/firebase_database.dart';
import 'package:ultiplay/models/game.dart';

class Games {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<bool> add(String userId, Game game) async {
    DatabaseReference games = _database.ref("games/$userId");
    DatabaseReference newGame = games.push();
    var data = game.toMap();
    return await newGame.set(data).then((onValue) {
      return true;
    }).catchError((onError) {
      return false;
    });
  }

  Future<List<Game>> list(String userId) async {
    DatabaseReference games = _database.ref("games/$userId");
    DatabaseEvent event = await games.once();
    if (!event.snapshot.exists || event.snapshot.value == null) {
      return [];
    }

    var rawList = event.snapshot.value as Map;
    if (rawList.isEmpty) {
      return [];
    }

    return rawList.entries.map((data) => Game.fromMap(data.value)).toList();
  }
}
