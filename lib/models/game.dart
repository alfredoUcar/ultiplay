import 'package:ultiplay/models/entities/game_summary.dart';

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
  String? _id;
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

  Game.fromMap(Map data)
      : _id = data.containsKey('id') ? data['id'] : null,
        _yourTeamName = data['your_team'],
        _opponentTeamName = data['opponent_team'],
        _yourScore = data['your_score'],
        _opponentScore = data['your_score'] + data['opponent_relative_score'],
        _division = Division.values.elementAt(data['division']),
        _modality = Modality.values.elementAt(data['modality']),
        _genderRule = data['gender_rule'] != null
            ? GenderRatioRule.values.elementAt(data['gender_rule'])
            : null,
        _genderRatio = data['gender_ratio'] != null
            ? GenderRatio.values.elementAt(data['gender_ratio'])
            : null,
        _startedAt = data['started_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['started_at'])
            : null,
        _endedAt = data['ended_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['ended_at'])
            : null,
        _yourSide = FieldSide.values.elementAt(data['your_side']),
        _yourPosition = Position.values.elementAt(data['your_position']);

  String? get id => _id;
  String get yourTeamName => _yourTeamName;
  FieldSide get yourTeamSide => _yourSide;
  String get opponentTeamName => _opponentTeamName;
  String get scoreboard => "$_yourScore - $_opponentScore";
  bool get isVictory => _endedAt != null && _yourScore > _opponentScore;
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

  bool finished() => endedAt != null;

  /// Played time in minutes and seconds, e.g., 114:23 for 1 hour, 54 minutes and 23 seconds.
  /// Time is calculated relative to [at] moment if provided or now.
  String getTime({DateTime? at}) {
    if (at == null) {
      at = DateTime.now();
    }
    var minDigits = 2;
    var padding = '0';
    var elapsed = at.difference(_startedAt as DateTime);
    var minutes = elapsed.inMinutes.toString().padLeft(minDigits, padding);
    var seconds =
        elapsed.inSeconds.remainder(60).toString().padLeft(minDigits, padding);
    return "$minutes:$seconds";
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

  GameSummary get summary => GameSummary(
        won: this.isVictory,
        title: '$_yourTeamName vs $_opponentTeamName',
        scoreboard: scoreboard,
        startedAt: _startedAt as DateTime,
      );

  Map<String, dynamic> toMap() => {
        'your_team': _yourTeamName,
        'opponent_team': _opponentTeamName,
        'your_score': _yourScore,
        'opponent_relative_score': _opponentScore - _yourScore,
        'division': _division.index,
        'modality': _modality.index,
        'gender_rule': _genderRule != null ? _genderRule!.index : null,
        'gender_ratio': _genderRatio != null ? _genderRatio!.index : null,
        'started_at':
            _startedAt != null ? _startedAt!.millisecondsSinceEpoch : null,
        'ended_at': _endedAt != null ? _endedAt!.millisecondsSinceEpoch : null,
        'your_side': _yourSide.index,
        'your_position': _yourPosition.index,
      };
}
