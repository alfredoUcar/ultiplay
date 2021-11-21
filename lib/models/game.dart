enum Position { offense, defense }
enum Gender { open, mixed, female }

/// Only for mixed games
enum GenderRatio { ruleA, ruleB }

class Game {
  String yourTeamName;
  String opponentTeamName;
  Gender gender;
  Position initialPosition;

  /// [genderRatio] should be only defined on mixed [gender] games
  GenderRatio? genderRatio;

  Game({
    required this.yourTeamName,
    required this.opponentTeamName,
    required this.initialPosition,
    this.gender = Gender.open,
    this.genderRatio,
  }) : assert(

            /// Validate that ratio is only defined on mixed games
            gender == Gender.mixed ? genderRatio != null : genderRatio == null);
}
