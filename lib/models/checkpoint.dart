enum CheckpointType { goal, turnover, pull, call, custom }
enum CallType {
  stall_out,
  fast_count,
  disc_scpace,
  double_team,
  contact,
  travel,
  throwing_foul,
  receiving_foul,
  blocking_foul,
  strip,
  injury,
  pick,
  violation
}

abstract class Checkpoint {
  DateTime _timestamp = DateTime.now();
  String team;
  CheckpointType _type;
  String? _notes;

  Checkpoint({required this.team, required CheckpointType type, String? notes})
      : _type = type,
        _notes = notes;

  CheckpointType get type => _type;
  String get description;
  String? get notes => _notes;

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
  String get description => 'Goal from $team ($_leftScore - $_rightScore)';
}

class Pull extends Checkpoint {
  Pull({
    required String team,
    String? notes,
  }) : super(team: team, type: CheckpointType.pull, notes: notes);

  @override
  String get description => 'Pull from $team';
}

class Turnover extends Checkpoint {
  Turnover({
    required String team,
    String? notes,
  }) : super(team: team, type: CheckpointType.turnover, notes: notes);

  @override
  String get description => 'Turnover while $team on offense';
}

class Call extends Checkpoint {
  bool? accepted;
  CallType? callType;

  Call({
    required String team,
    String? notes,
    this.accepted,
    this.callType,
  }) : super(team: team, type: CheckpointType.call, notes: notes);

  @override
  String get description => 'Call from $team';
}

class Custom extends Checkpoint {
  Custom({
    required String team,
    String? notes,
  }) : super(team: team, type: CheckpointType.custom, notes: notes);

  @override
  String get description =>
      'Checkpoint for $team' + (_notes != null ? ': $_notes' : '');
}
