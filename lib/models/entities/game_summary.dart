class GameSummary {
  String? gameId;
  bool won;
  String title;
  String scoreboard;
  DateTime startedAt;

  GameSummary({
    this.gameId,
    required this.won,
    required this.title,
    required this.scoreboard,
    required this.startedAt,
  });

  GameSummary.fromMap(Map data)
      : gameId = data['game_id'],
        won = data['won'],
        title = data['title'],
        scoreboard = data['scoreboard'],
        startedAt = DateTime.fromMillisecondsSinceEpoch(data['started_at']);

  Map<String, dynamic> toMap() => {
        'game_id': gameId,
        'won': won,
        'title': title,
        'scoreboard': scoreboard,
        'started_at': startedAt.millisecondsSinceEpoch,
      };
}
