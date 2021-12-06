enum Position { offense, defense }
enum Division { open, mixed, women, master, grandmaster }
enum CheckpointType { goal, turnover, pull, call, custom }
enum FieldSide { left, right }
enum Modality { grass, beach, indoor }

/// Only for mixed games
enum GenderRatioRule { ruleA, ruleB }
enum GenderRatio { moreWomen, moreMen }

class AlreadyStarted implements Exception {}

class AlreadyEnded implements Exception {}

class MissingGenderRatio implements Exception {}

class Checkpoint {
  DateTime _timestamp = DateTime.now();
  String _team;
  CheckpointType _type;
  String? _notes;

  Checkpoint(
      {required String team, required CheckpointType type, String? notes})
      : _team = team,
        _type = type,
        _notes = notes;

  @override
  String toString() {
    switch (_type) {
      case CheckpointType.goal:
        return 'Goal from $_team';
      case CheckpointType.pull:
        return 'Pull from $_team';
      case CheckpointType.turnover:
        return 'Turnover while $_team on offense';
      case CheckpointType.call:
        return 'Call from $_team';
      default:
        return 'Checkpoint for $_team' + (_notes != null ? ': $_notes' : '');
    }
  }

  DateTime get timestamp => _timestamp;
}

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
  List<Checkpoint> _checkpoints = [];

  /// [genderRatioRule] should be only defined on mixed [gender] games
  GenderRatioRule? _genderRule;
  GenderRatio? _genderRatio; // only for rule A
  FieldSide? _endzoneA; // only for rule B

  DateTime? _startedAt, _endedAt;

  Game({
    required String yourTeamName,
    required String opponentTeamName,
    required Position initialPosition,
    required FieldSide initialSide,
    Division division = Division.open,
    Modality modality = Modality.grass,
    GenderRatioRule? genderRule,
    GenderRatio? initialGenderRatio,
  })  : _yourTeamName = yourTeamName,
        _opponentTeamName = opponentTeamName,
        _division = division,
        _modality = modality,
        _genderRule = genderRule,
        _genderRatio = initialGenderRatio,
        _yourPosition = initialPosition,
        _yourSide = initialSide,
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

  void goal() {
    if (onOffense()) {
      _yourScore++;
      _checkpoints
          .add(new Checkpoint(team: _yourTeamName, type: CheckpointType.goal));
    } else {
      _opponentScore++;
      _checkpoints.add(
          new Checkpoint(team: _opponentTeamName, type: CheckpointType.goal));
    }

    switchSide();

    if (appliesGenderRuleA()) {
      updateGenderRatio();
    }

    _isPullTime = true;
  }

  void pull() {
    var pullFrom = onDefense() ? _yourTeamName : _opponentTeamName;
    _checkpoints.add(new Checkpoint(team: pullFrom, type: CheckpointType.pull));
    _isPullTime = false;
  }

  void turnover() {
    if (onOffense()) {
      _yourPosition = Position.defense;
      _checkpoints.add(
          new Checkpoint(team: _yourTeamName, type: CheckpointType.turnover));
    } else {
      _yourPosition = Position.offense;
      _checkpoints.add(new Checkpoint(
          team: _opponentTeamName, type: CheckpointType.turnover));
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
}
