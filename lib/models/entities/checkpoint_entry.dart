import 'package:ultiplay/models/checkpoint.dart';

class CheckpointEntry {
  String? gameId;
  String? id;
  CheckpointType type;
  String description;
  DateTime timestamp;

  CheckpointEntry({
    this.gameId,
    this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  CheckpointEntry.fromMap(Map data)
      : gameId = data['game_id'],
        id = data['id'],
        type = CheckpointType.values.elementAt(data['type']),
        description = data['description'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);

  Map<String, dynamic> toMap() => {
        'game_id': gameId,
        'id': id,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'type': type.index,
        'description': description,
      };
}
