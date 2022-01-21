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

  Map<String, dynamic> toMap() => {
        'game_id': gameId,
        'won': won,
        'title': title,
        'scoreboard': scoreboard,
        'started_at': startedAt.millisecondsSinceEpoch,
      };
}
