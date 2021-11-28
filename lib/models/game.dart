enum Position { offense, defense }
enum Gender { open, mixed, female }
enum CheckpointType { goal, turnover, pull, call, custom }

/// Only for mixed games
enum GenderRatio { ruleA, ruleB }

class AlreadyStarted implements Exception {}

class AlreadyEnded implements Exception {}

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
  Gender _gender;
  Position _yourPosition;
  int _yourScore = 0;
  int _opponentScore = 0;
  bool _isPullTime = true;
  List<Checkpoint> _checkpoints = [];

  /// [genderRatio] should be only defined on mixed [gender] games
  GenderRatio? _genderRatio;

  DateTime? _startedAt, _endedAt;

  Game({
    required String yourTeamName,
    required String opponentTeamName,
    required Position initialPosition,
    Gender gender = Gender.open,
    GenderRatio? genderRatio,
  })  : _yourTeamName = yourTeamName,
        _opponentTeamName = opponentTeamName,
        _gender = gender,
        _genderRatio = genderRatio,
        _yourPosition = initialPosition,
        assert(

            /// Validate that ratio is only defined on mixed games
            gender == Gender.mixed ? genderRatio != null : genderRatio == null);

  String get yourTeamName => _yourTeamName;
  String get opponentTeamName => _opponentTeamName;
  int get yourScore => _yourScore;
  int get opponentScore => _opponentScore;

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

  Duration getElapsed() => DateTime.now().difference(_startedAt as DateTime);

  bool onOffense() => _yourPosition.index == Position.offense.index;
  bool onDefense() => _yourPosition.index == Position.defense.index;
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
    _isPullTime = true;
  }

  void pull() {
    var pullFrom = onDefense() ? _yourTeamName : _opponentTeamName;
    _checkpoints.add(new Checkpoint(team: pullFrom, type: CheckpointType.pull));
    _isPullTime = false;
  }

  void turnover() {
    if (onOffense()) {
      _yourScore++;
      _checkpoints.add(
          new Checkpoint(team: _yourTeamName, type: CheckpointType.turnover));
    } else {
      _opponentScore++;
      _checkpoints.add(new Checkpoint(
          team: _opponentTeamName, type: CheckpointType.turnover));
    }
  }

  List<Checkpoint> get checkpoints => _checkpoints;
}
