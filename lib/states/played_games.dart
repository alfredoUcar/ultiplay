import 'package:flutter/widgets.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/repositories/games.dart';

class PlayedGames extends ChangeNotifier {
  List<Game> _playedGames = [];
  late Games _games;

  bool _fetched = false;
  bool _fetching = false;

  PlayedGames() {
    _games = Games();
  }

  void fetch(String userId) {
    _fetching = true;
    notifyListeners();

    _games.list(userId).then((games) {
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

  List<Game> get list => List.from(_playedGames);
}
