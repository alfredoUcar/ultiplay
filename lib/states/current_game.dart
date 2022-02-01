import 'package:flutter/widgets.dart';
import 'package:ultiplay/models/checkpoint.dart';
import 'package:ultiplay/models/entities/game_summary.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/repositories/games.dart';

class IsEmpty implements Exception {}

class CurrentGame extends ChangeNotifier implements Game {
  Game? _game;
  late Games _games;

  CurrentGame() {
    _games = Games();
  }

  set game(Game game) {
    _game = game;
    notifyListeners();
  }

  Game? getGame() => _game;

  bool isEmpty() => _game == null;

  clear() {
    if (_game != null) {
      _game = null;
      notifyListeners();
    }
  }

  @override
  bool appliesGenderRuleA() => _game!.appliesGenderRuleA();

  @override
  bool appliesGenderRuleB() => _game!.appliesGenderRuleB();

  @override
  void call() {
    _game!.call();
    notifyListeners();
  }

  @override
  void callAccepted() {
    _game!.callAccepted();
    notifyListeners();
  }

  @override
  void callContested() {
    _game!.callContested();
    notifyListeners();
  }

  @override
  Call? get callInProgress => _game!.callInProgress;

  @override
  void callIsAccepted(bool value) {
    _game!.callIsAccepted(value);
    notifyListeners();
  }

  @override
  List<Checkpoint> get checkpoints => _game!.checkpoints;

  @override
  void discardCall() {
    _game!.discardCall();
    notifyListeners();
  }

  @override
  void endCall() {
    _game!.endCall();
    notifyListeners();
  }

  @override
  DateTime? get endedAt => _game!.endedAt;

  @override
  void finish() {
    _game!.finish();
    notifyListeners();
  }

  Future<bool> save(String userId) async {
    return _games.add(userId, _game as Game);
  }

  @override
  int getRequiredWomenOnLine() => _game!.getRequiredWomenOnLine();

  @override
  String getTime({DateTime? at}) => _game!.getTime(at: at);

  @override
  void goal() {
    _game!.goal();
    notifyListeners();
  }

  @override
  void halfTime() {
    _game!.halfTime();
    notifyListeners();
  }

  @override
  bool isHalftimeReached() {
    return _game!.isHalftimeReached();
  }

  @override
  bool isMixed() {
    return _game!.isMixed();
  }

  @override
  bool isOnCall() {
    return _game!.isOnCall();
  }

  @override
  bool isPullTime() {
    return _game!.isPullTime();
  }

  @override
  bool get isVictory => _game!.isVictory;

  @override
  bool onDefense() {
    return _game!.onDefense();
  }

  @override
  bool onOffense() {
    return _game!.onOffense();
  }

  @override
  String get opponentTeamName => _game!.opponentTeamName;

  @override
  void pull() {
    _game!.pull();
    notifyListeners();
  }

  @override
  String get scoreboard => _game!.scoreboard;

  @override
  void start() {
    _game!.start();
    notifyListeners();
  }

  @override
  DateTime? get startedAt => _game!.startedAt;

  @override
  void switchSide() {
    _game!.switchSide();
    notifyListeners();
  }

  @override
  void turnover() {
    _game!.turnover();
    notifyListeners();
  }

  @override
  void undoGoal(String fromTeam) {
    _game!.undoGoal(fromTeam);
    notifyListeners();
  }

  @override
  void undoLastCheckpoint() {
    _game!.undoLastCheckpoint();
    notifyListeners();
  }

  @override
  void undoPull() {
    _game!.undoPull();
    notifyListeners();
  }

  @override
  void updateGenderRatio() {
    _game!.updateGenderRatio();
    notifyListeners();
  }

  @override
  bool yourTeamChoosesGender() {
    return _game!.yourTeamChoosesGender();
  }

  @override
  String get yourTeamName => _game!.yourTeamName;

  @override
  FieldSide get yourTeamSide => _game!.yourTeamSide;

  @override
  bool finished() => _game!.finished();

  @override
  String? get id => _game!.id;

  @override
  GameSummary get summary => _game!.summary;

  @override
  Map<String, dynamic> toMap() {
    return _game != null ? _game!.toMap() : {};
  }
}
