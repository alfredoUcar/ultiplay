import 'package:flutter/widgets.dart';
import 'package:ultiplay/models/entities/game_summary.dart';
import 'package:ultiplay/repositories/games.dart';

class PlayedGames extends ChangeNotifier {
  List<GameSummary> _playedGames = [];
  late Games _games;

  bool _fetched = false;
  bool _fetching = false;

  PlayedGames() {
    _games = Games();
  }

  void fetch(String userId) {
    _fetching = true;
    notifyListeners();

    _games.listSummaries(userId).then((games) {
      _fetched = true;
      _fetching = false;
      _playedGames = games;
      notifyListeners();
    });
  }

  bool fetching() => _fetching;
  bool fetched() => _fetched;

  bool isEmpty() => _playedGames.isEmpty;

  get length => _playedGames.length;

  List<GameSummary> get list => List.from(_playedGames);

  Future<bool> delete(String userId, String gameId) async {
    return _games.delete(userId, gameId).then((deleted) {
      if (deleted) {
        _playedGames.removeWhere((game) => game.gameId == gameId);
        notifyListeners();
      }
      return deleted;
    });
  }
}
