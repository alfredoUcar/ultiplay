import 'checkpoint.dart';

enum Position { offense, defense }
enum Division { open, mixed, women, master, grandmaster }
enum FieldSide { left, right }
enum Modality { grass, beach, indoor }

/// Only for mixed games
enum GenderRatioRule { ruleA, ruleB }
enum GenderRatio { moreWomen, moreMen }

class AlreadyStarted implements Exception {}

class AlreadyEnded implements Exception {}

class MissingGenderRatio implements Exception {}

class HalfTimeAlreadyReached implements Exception {}

class AnyCheckpointAvailableToUndo implements Exception {}

class Game {
  String _yourTeamName;
  String _opponentTeamName;
  Division _division;
  Modality _modality;
  Position _yourPosition;
  FieldSide _yourSide;
  int _yourScore = 0;
  int _opponentScore = 0;
  bool _isPullTime = true;
  bool _halfTimeReached = false;
  List<Checkpoint> _checkpoints = [];

  /// [genderRatioRule] should be only defined on mixed [gender] games
  GenderRatioRule? _genderRule;
  GenderRatio? _genderRatio; // only for rule A
  FieldSide? _endzoneA; // only for rule B

  DateTime? _startedAt, _endedAt;

  Call? _callInProgress;

  Game({
    required String yourTeamName,
    required String opponentTeamName,
    required Position initialPosition,
    required FieldSide initialSide,
    Division division = Division.open,
    Modality modality = Modality.grass,
    GenderRatioRule? genderRule,
    GenderRatio? initialGenderRatio,
    FieldSide? endzoneA,
  })  : _yourTeamName = yourTeamName,
        _opponentTeamName = opponentTeamName,
        _division = division,
        _modality = modality,
        _genderRule = genderRule,
        _genderRatio = initialGenderRatio,
        _yourPosition = initialPosition,
        _yourSide = initialSide,
        _endzoneA = endzoneA,
        assert(

            /// Validate that ratio is only defined on mixed games
            division == Division.mixed
                ? genderRule != null
                : genderRule == null);

  String get yourTeamName => _yourTeamName;
  FieldSide get yourTeamSide => _yourSide;
  String get opponentTeamName => _opponentTeamName;
  int get yourScore => _yourScore;
  int get opponentScore => _opponentScore;
  int get _playedPoints => _yourScore + _opponentScore;
  DateTime? get startedAt => _startedAt;
  DateTime? get endedAt => _endedAt;

  void start() {
    if (_startedAt != null) {
      throw AlreadyStarted();
    }

    _startedAt = DateTime.now();
  }

  void finish() {
    if (_endedAt != null) {
      throw AlreadyEnded();
    }

    _endedAt = DateTime.now();
  }

  Duration getElapsed({DateTime? at}) {
    if (at == null) {
      at = DateTime.now();
    }

    return at.difference(_startedAt as DateTime);
  }

  bool onOffense() => _yourPosition == Position.offense;
  bool onDefense() => _yourPosition == Position.defense;
  bool isPullTime() => _isPullTime;
  bool isHalftimeReached() => _halfTimeReached;

  void goal() {
    if (onOffense()) {
      _yourScore++;
      _checkpoints.add(Goal(
          team: _yourTeamName,
          leftScore: _yourScore,
          rightScore: _opponentScore));
      _yourPosition = Position.defense;
    } else {
      _opponentScore++;
      _checkpoints.add(Goal(
          team: _opponentTeamName,
          leftScore: _yourScore,
          rightScore: _opponentScore));
      _yourPosition = Position.offense;
    }

    switchSide();

    if (appliesGenderRuleA()) {
      updateGenderRatio();
    }

    _isPullTime = true;
  }

  void undoGoal(String fromTeam) {
    if (fromTeam == yourTeamName) {
      _yourScore--;
    } else {
      _opponentScore--;
    }

    switchSide();

    if (appliesGenderRuleA()) {
      updateGenderRatio();
    }

    _isPullTime = false;
  }

  void pull() {
    var pullFrom = onDefense() ? _yourTeamName : _opponentTeamName;
    _checkpoints.add(Pull(team: pullFrom));
    _isPullTime = false;
  }

  void undoPull() {
    _isPullTime = true;
  }

  void turnover() {
    if (onOffense()) {
      _yourPosition = Position.defense;
      _checkpoints.add(Turnover(team: _yourTeamName));
    } else {
      _yourPosition = Position.offense;
      _checkpoints.add(Turnover(team: _opponentTeamName));
    }
  }

  List<Checkpoint> get checkpoints => _checkpoints;

  void switchSide() {
    if (_yourSide == FieldSide.left) {
      _yourSide = FieldSide.right;
    } else {
      _yourSide = FieldSide.left;
    }
  }

  bool isMixed() {
    return _division == Division.mixed;
  }

  /// Only when playing a mixed division game
  bool appliesGenderRuleA() => _genderRule == GenderRatioRule.ruleA;
  bool appliesGenderRuleB() => _genderRule == GenderRatioRule.ruleB;

  /// Only with gender rule A
  int getRequiredWomenOnLine() {
    if (_genderRatio == null) {
      throw MissingGenderRatio();
    }

    if (_genderRatio == GenderRatio.moreWomen) {
      if (_modality == Modality.grass) {
        return 4; // and 3 men
      } else {
        return 3; // and 2 men
      }
    }

    /// GenderRatio.moreMen
    if (_modality == Modality.grass) {
      return 3; // and 4 men
    } else {
      return 2; // and 3 mens
    }
  }

  /// Only with gender rule B
  bool yourTeamChoosesGender() {
    print('${_yourSide.toString()}-${_endzoneA.toString()}');
    return _yourSide == _endzoneA;
  }

  void updateGenderRatio() {
    if (_playedPoints == 1 || _playedPoints.isEven) {
      if (_genderRatio == GenderRatio.moreMen) {
        _genderRatio = GenderRatio.moreWomen;
      } else {
        _genderRatio = GenderRatio.moreMen;
      }
    }
  }

  Call? get callInProgress => _callInProgress;

  void call() {
    _callInProgress = Call(team: yourTeamName);
  }

  void discardCall() {
    _callInProgress = null;
  }

  void callIsAccepted(bool value) {
    _callInProgress!.accepted = value;
  }

  void callAccepted() {
    _callInProgress!.accepted = true;
    endCall();
  }

  void callContested() {
    _callInProgress!.accepted = false;
    endCall();
  }

  void endCall() {
    if (_callInProgress != null) {
      _checkpoints.add(_callInProgress!);
      _callInProgress = null;
    }
  }

  bool isOnCall() => _callInProgress != null;

  void halfTime() {
    if (_halfTimeReached) {
      throw HalfTimeAlreadyReached();
    }

    switchSide();

    if (appliesGenderRuleB()) {
      if (_endzoneA == FieldSide.left) {
        _endzoneA = FieldSide.right;
      } else {
        _endzoneA = FieldSide.left;
      }
    }

    _halfTimeReached = true;
  }

  void undoLastCheckpoint() {
    if (checkpoints.isEmpty) {
      throw AnyCheckpointAvailableToUndo();
    }

    var lastCheckpoint = checkpoints.last;

    if (lastCheckpoint is Pull) {
      undoPull();
    } else if (lastCheckpoint is Goal) {
      undoGoal(lastCheckpoint.team);
    }

    checkpoints.removeLast();
  }
}
