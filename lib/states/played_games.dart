import 'package:flutter/widgets.dart';
import 'package:ultiplay/models/game.dart';

class PlayedGames extends ChangeNotifier {
  final List<Game> _playedGames = [];

  set currentGame(Game? game) {
    if (game != null && game.finished()) {
      _playedGames.add(game);
      notifyListeners();
    }
  }

  void add(Game game) {
    _playedGames.add(game);
    notifyListeners();
  }

  bool isEmpty() => _playedGames.isEmpty;

  void empty() {
    _playedGames.clear();
    notifyListeners();
  }

  get length => _playedGames.length;

  List<Game> get list => List.unmodifiable(_playedGames);
}
