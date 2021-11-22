enum Position { offense, defense }
enum Gender { open, mixed, female }

/// Only for mixed games
enum GenderRatio { ruleA, ruleB }

class Game {
  String _yourTeamName;
  String _opponentTeamName;
  Gender _gender;
  Position _initialPosition;

  /// [genderRatio] should be only defined on mixed [gender] games
  GenderRatio? _genderRatio;

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
        _initialPosition = initialPosition,
        assert(

            /// Validate that ratio is only defined on mixed games
            gender == Gender.mixed ? genderRatio != null : genderRatio == null);

  String get yourTeamName => _yourTeamName;
  String get opponentTeamName => _opponentTeamName;
}
