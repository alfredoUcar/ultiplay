import 'package:firebase_database/firebase_database.dart';
import 'package:ultiplay/models/entities/game_summary.dart';
import 'package:ultiplay/models/game.dart';

class Games {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<bool> add(String userId, Game game) async {
    DatabaseReference games = _database.ref("games/$userId");
    DatabaseReference newGame = games.push();
    var data = game.toMap();
    return await newGame.set(data).then((onValue) async {
      await _addSummary(userId, game, newGame.key as String);
      _addCheckpoints(userId, game, newGame.key as String);
      return true;
    }).catchError((onError) {
      return false;
    });
  }

  Future<bool> _addSummary(String userId, Game game, String gameId) async {
    DatabaseReference userGameSummary =
        _database.ref("users/$userId/games/$gameId");
    var data = game.summary.toMap();
    return await userGameSummary.set(data).then((onValue) {
      return true;
    }).catchError((onError) {
      return false;
    });
  }

  void _addCheckpoints(String userId, Game game, String gameId) async {
    DatabaseReference gameCheckpoints =
        _database.ref("checkpoints/$userId/$gameId");
    game.checkpoints.forEach((checkpoint) async {
      DatabaseReference newCheckpoint = gameCheckpoints.push();
      await newCheckpoint.set(checkpoint.toMap());
    });
  }

  Future<bool> delete(String userId, String gameId) async {
    DatabaseReference game = _database.ref("games/$userId/$gameId");
    return await game.remove().then((onValue) async {
      await _deleteSummary(userId, gameId);
      await _deleteChekpoints(userId, gameId);
      return true;
    }).catchError((onError) {
      return false;
    });
  }

  Future<bool> _deleteSummary(String userId, String gameId) async {
    DatabaseReference game = _database.ref("users/$userId/games/$gameId");
    return await game.remove().then((onValue) {
      return true;
    }).catchError((onError) {
      return false;
    });
  }

  Future<bool> _deleteChekpoints(String userId, String gameId) async {
    DatabaseReference gameCheckpoints =
        _database.ref("checkpoints/$userId/$gameId");
    return await gameCheckpoints.remove().then((onValue) {
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

    return rawList.entries.map((data) {
      var gameData = data.value;
      gameData['id'] = data.key;
      return Game.fromMap(data.value);
    }).toList();
  }

  Future<List<GameSummary>> listSummaries(String userId) async {
    DatabaseReference games = _database.ref("users/$userId/games");
    DatabaseEvent event = await games.once();
    if (!event.snapshot.exists || event.snapshot.value == null) {
      return [];
    }

    var rawList = event.snapshot.value as Map;
    if (rawList.isEmpty) {
      return [];
    }

    return rawList.entries.map((data) {
      var gameData = data.value;
      gameData['game_id'] = data.key;
      return GameSummary.fromMap(data.value);
    }).toList();
  }
}
