enum CheckpointType { goal, turnover, pull, call, custom }

abstract class Checkpoint {
  DateTime _timestamp = DateTime.now();
  String _team;
  CheckpointType _type;
  String? _notes;

  Checkpoint(
      {required String team, required CheckpointType type, String? notes})
      : _team = team,
        _type = type,
        _notes = notes;

  CheckpointType get type => _type;
  String? get notes => _notes;
  String get description;

  @override
  String toString() => description;

  DateTime get timestamp => _timestamp;
}

class Goal extends Checkpoint {
  int _leftScore, _rightScore;

  Goal({
    required String team,
    required int leftScore,
    required int rightScore,
    String? notes,
  })  : _leftScore = leftScore,
        _rightScore = rightScore,
        super(team: team, type: CheckpointType.goal, notes: notes);

  int get leftScore => _leftScore;
  int get rigthScore => _rightScore;

  @override
  String get description => 'Goal from $_team ($_leftScore - $_rightScore)';
}

class Pull extends Checkpoint {
  Pull({
    required String team,
    String? notes,
  }) : super(team: team, type: CheckpointType.pull, notes: notes);

  @override
  String get description => 'Pull from $_team';
}

class Turnover extends Checkpoint {
  Turnover({
    required String team,
    String? notes,
  }) : super(team: team, type: CheckpointType.turnover, notes: notes);

  @override
  String get description => 'Turnover while $_team on offense';
}

class Call extends Checkpoint {
  Call({
    required String team,
    String? notes,
  }) : super(team: team, type: CheckpointType.call, notes: notes);

  @override
  String get description => 'Call from $_team';
}

class Custom extends Checkpoint {
  Custom({
    required String team,
    String? notes,
  }) : super(team: team, type: CheckpointType.custom, notes: notes);

  @override
  String get description =>
      'Checkpoint for $_team' + (_notes != null ? ': $_notes' : '');
}
